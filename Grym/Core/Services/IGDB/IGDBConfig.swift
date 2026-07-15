//
//  IGDBConfig.swift
//  Grym
//
//  Configuration d'accès à l'API IGDB (metadata jeux).
//  IGDB s'authentifie via l'OAuth « client credentials » de Twitch.
//
//  ⚠️ Clés de développement : à remplacer par un backend / secret sécurisé
//  avant la mise en production (ne jamais livrer un secret dans le binaire).
//

import Foundation

nonisolated enum IGDBConfig {

    /// Identifiant client Twitch (aussi utilisé comme header `Client-ID` IGDB).
    static let clientID = "i4fdk3v21n4w9nk17l0k3zxqdyl4dc"

    /// Secret client Twitch (échange de token uniquement).
    static let clientSecret = "7jfbjhmvb61veeqva7k4p6pp1nz4rv"

    // URLs littérales validées à la compilation : force unwrap justifié.
    /// Endpoint OAuth Twitch pour obtenir un token « client credentials ».
    static let tokenURL = URL(string: "https://id.twitch.tv/oauth2/token")!

    /// Base de l'API IGDB v4.
    static let apiBaseURL = URL(string: "https://api.igdb.com/v4")!

    /// Marge de sécurité (s) retranchée à l'expiration du token pour anticiper le refresh.
    static let tokenExpiryMargin: TimeInterval = 60
}
