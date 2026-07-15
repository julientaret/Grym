//
//  IGDBModels.swift
//  Grym
//
//  DTO de réponse de l'API IGDB et helpers de présentation.
//  Décodage en `convertFromSnakeCase` (cf. IGDBService).
//

import Foundation

// MARK: - Token Twitch

/// Réponse de l'endpoint OAuth Twitch (`client_credentials`).
nonisolated struct IGDBTokenResponse: Decodable, Sendable {
    let accessToken: String
    let expiresIn: Int
    let tokenType: String
}

// MARK: - Jeu

/// Un jeu tel que renvoyé par l'endpoint `/games` d'IGDB.
nonisolated struct IGDBGame: Decodable, Identifiable, Sendable, Hashable {
    let id: Int
    let name: String
    let slug: String?
    let firstReleaseDate: Int?
    let cover: IGDBCover?
    let platforms: [IGDBPlatform]?
}

/// Cover d'un jeu (image hébergée sur le CDN IGDB).
nonisolated struct IGDBCover: Decodable, Sendable, Hashable {
    let id: Int?
    let imageId: String?
}

/// Plateforme d'un jeu (PS5, PC, Switch…).
nonisolated struct IGDBPlatform: Decodable, Sendable, Hashable {
    let id: Int
    let name: String?
    let abbreviation: String?
}

// MARK: - Présentation

/// Tailles d'image disponibles sur le CDN IGDB.
nonisolated enum IGDBImageSize: String {
    case coverSmall     = "t_cover_small"
    case coverBig       = "t_cover_big"
    case cover2xBig     = "t_cover_big_2x"
    case thumb          = "t_thumb"
    case screenshotMed  = "t_screenshot_med"

    /// URL CDN IGDB de l'image pour un `image_id` donné.
    func url(imageId: String) -> URL? {
        URL(string: "https://images.igdb.com/igdb/image/upload/\(rawValue)/\(imageId).jpg")
    }
}

extension IGDBGame {

    /// Année de sortie déduite du timestamp Unix IGDB, si disponible.
    var releaseYear: Int? {
        guard let firstReleaseDate else { return nil }
        let date = Date(timeIntervalSince1970: TimeInterval(firstReleaseDate))
        return Calendar(identifier: .gregorian).component(.year, from: date)
    }

    /// Libellé plateforme le plus court disponible (abréviation en priorité).
    var primaryPlatform: String? {
        guard let platform = platforms?.first else { return nil }
        return platform.abbreviation ?? platform.name
    }

    /// URL de la cover pour une taille donnée, ou `nil` si le jeu n'en a pas.
    func coverURL(size: IGDBImageSize = .coverBig) -> URL? {
        cover?.imageId.flatMap { size.url(imageId: $0) }
    }
}
