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
    let cover: IGDBImage?
}

/// Image hébergée sur le CDN IGDB (cover, screenshot ou artwork).
/// Seul `image_id` sert : il suffit à reconstruire l'URL à n'importe quelle taille.
nonisolated struct IGDBImage: Decodable, Sendable, Hashable {
    let id: Int?
    let imageId: String?
}

/// Réponse de `gameMedia(id:)`.
///
/// DTO distinct d'`IGDBGame` : la requête média ne demande que les images, et
/// ne renvoie donc pas les champs obligatoires du jeu (`name`…). La décoder en
/// `IGDBGame` échouerait.
nonisolated struct IGDBGameMediaResponse: Decodable, Sendable {
    let screenshots: [IGDBImage]?
    let artworks: [IGDBImage]?

    var media: IGDBGameMedia {
        IGDBGameMedia(
            screenshotImageIds: screenshots?.compactMap(\.imageId) ?? [],
            artworkImageIds: artworks?.compactMap(\.imageId) ?? []
        )
    }
}

/// Médias d'un jeu, tels que persistés sur `Game`.
nonisolated struct IGDBGameMedia: Sendable, Equatable {
    let screenshotImageIds: [String]
    let artworkImageIds: [String]

    static let empty = IGDBGameMedia(screenshotImageIds: [], artworkImageIds: [])
}

// MARK: - Présentation

/// Tailles d'image disponibles sur le CDN IGDB.
nonisolated enum IGDBImageSize: String {
    case coverSmall     = "t_cover_small"
    case coverBig       = "t_cover_big"
    case cover2xBig     = "t_cover_big_2x"
    case thumb          = "t_thumb"
    case screenshotMed  = "t_screenshot_med"    // 569 × 320 — vignettes de galerie
    case screenshotBig  = "t_screenshot_big"    // 889 × 500 — bandeau d'en-tête
    case fullHD         = "t_1080p"             // 1920 × 1080 — visionneuse plein écran

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

    /// URL de la cover pour une taille donnée, ou `nil` si le jeu n'en a pas.
    func coverURL(size: IGDBImageSize = .coverBig) -> URL? {
        cover?.imageId.flatMap { size.url(imageId: $0) }
    }
}
