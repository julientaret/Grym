//
//  IGDBError.swift
//  Grym
//
//  Erreurs remontées par le service IGDB.
//

import Foundation

nonisolated enum IGDBError: LocalizedError {
    /// Réponse HTTP absente ou non exploitable.
    case invalidResponse
    /// Échec de l'authentification Twitch (obtention du token).
    case authenticationFailed(status: Int)
    /// Requête IGDB rejetée (status HTTP non 2xx).
    case requestFailed(status: Int)
    /// Décodage JSON impossible.
    case decodingFailed(underlying: Error)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Réponse invalide du serveur IGDB."
        case .authenticationFailed(let status):
            return "Échec d'authentification IGDB (HTTP \(status))."
        case .requestFailed(let status):
            return "Requête IGDB échouée (HTTP \(status))."
        case .decodingFailed(let underlying):
            return "Décodage de la réponse IGDB impossible : \(underlying.localizedDescription)"
        }
    }
}
