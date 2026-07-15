//
//  IGDBService.swift
//  Grym
//
//  Accès à l'API IGDB : gestion du token OAuth Twitch (cache + refresh
//  automatique) et requêtes APICalypse sur l'endpoint `/games`.
//
//  Implémenté en `actor` : le cache de token est ainsi protégé des accès
//  concurrents sans verrou explicite.
//

import Foundation

// MARK: - Protocole

/// Contrat du service IGDB (permet l'injection d'un mock dans les ViewModels).
protocol IGDBServiceProtocol: Sendable {
    /// Recherche de jeux par titre. Retourne au plus `limit` résultats.
    func searchGames(matching query: String, limit: Int) async throws -> [IGDBGame]
}

extension IGDBServiceProtocol {
    func searchGames(matching query: String) async throws -> [IGDBGame] {
        try await searchGames(matching: query, limit: 20)
    }
}

// MARK: - Implémentation

actor IGDBService: IGDBServiceProtocol {

    static let shared = IGDBService()

    private let session: URLSession
    private let decoder: JSONDecoder

    /// Token courant et sa date d'expiration effective (marge déjà appliquée).
    private var cachedToken: (value: String, expiresAt: Date)?

    init(session: URLSession = .shared) {
        self.session = session
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        self.decoder = decoder
    }

    // MARK: Recherche

    func searchGames(matching query: String, limit: Int) async throws -> [IGDBGame] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return [] }

        // Échappe les guillemets pour ne pas casser la requête APICalypse.
        let sanitized = trimmed.replacingOccurrences(of: "\"", with: "")

        let apicalypse = """
        search "\(sanitized)"; \
        fields name, slug, first_release_date, cover.image_id, \
        platforms.name, platforms.abbreviation; \
        where cover != null; \
        limit \(max(1, limit));
        """

        let data = try await performRequest(path: "games", body: apicalypse)

        do {
            return try decoder.decode([IGDBGame].self, from: data)
        } catch {
            throw IGDBError.decodingFailed(underlying: error)
        }
    }

    // MARK: Requête IGDB

    /// Exécute une requête APICalypse authentifiée sur un endpoint IGDB.
    private func performRequest(path: String, body: String) async throws -> Data {
        let token = try await validToken()

        let url = IGDBConfig.apiBaseURL.appendingPathComponent(path)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(IGDBConfig.clientID, forHTTPHeaderField: "Client-ID")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("text/plain", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpBody = Data(body.utf8)

        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse else {
            throw IGDBError.invalidResponse
        }
        guard (200..<300).contains(http.statusCode) else {
            throw IGDBError.requestFailed(status: http.statusCode)
        }
        return data
    }

    // MARK: Authentification

    /// Retourne un token valide, depuis le cache ou en le renouvelant.
    private func validToken() async throws -> String {
        if let cachedToken, cachedToken.expiresAt > Date() {
            return cachedToken.value
        }
        return try await refreshToken()
    }

    /// Obtient un nouveau token « client credentials » auprès de Twitch et le cache.
    private func refreshToken() async throws -> String {
        var components = URLComponents(url: IGDBConfig.tokenURL, resolvingAgainstBaseURL: false)
        components?.queryItems = [
            URLQueryItem(name: "client_id", value: IGDBConfig.clientID),
            URLQueryItem(name: "client_secret", value: IGDBConfig.clientSecret),
            URLQueryItem(name: "grant_type", value: "client_credentials")
        ]
        guard let url = components?.url else { throw IGDBError.invalidResponse }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse else {
            throw IGDBError.invalidResponse
        }
        guard (200..<300).contains(http.statusCode) else {
            throw IGDBError.authenticationFailed(status: http.statusCode)
        }

        let token: IGDBTokenResponse
        do {
            token = try decoder.decode(IGDBTokenResponse.self, from: data)
        } catch {
            throw IGDBError.decodingFailed(underlying: error)
        }

        let expiry = Date().addingTimeInterval(
            TimeInterval(token.expiresIn) - IGDBConfig.tokenExpiryMargin
        )
        cachedToken = (value: token.accessToken, expiresAt: expiry)
        return token.accessToken
    }
}
