//
//  Game.swift
//  Grym
//
//  Métadonnées d'un jeu (issues d'IGDB). Dé-doublonné par `igdbId`.
//

import Foundation
import SwiftData

@Model
final class Game {
    /// Identifiant IGDB, sert de clé de dé-doublonnage.
    var igdbId: Int
    var title: String
    /// `image_id` IGDB de la jaquette ; l'URL est reconstruite à la demande.
    var coverImageId: String?
    var slug: String?
    var releaseYear: Int?

    /// `image_id` IGDB des captures d'écran du jeu.
    var screenshotImageIds: [String] = []
    /// `image_id` IGDB des illustrations (key art) du jeu.
    var artworkImageIds: [String] = []
    /// Date du dernier appel média abouti. `nil` = jamais récupérés, à charger
    /// à la prochaine ouverture du wiki (couvre les jeux ajoutés avant la feature).
    var mediaFetchedAt: Date?

    /// Wikis rattachés à ce jeu (supprimés en cascade avec le jeu).
    @Relationship(deleteRule: .cascade, inverse: \Wiki.game)
    var wikis: [Wiki] = []

    init(
        igdbId: Int,
        title: String,
        coverImageId: String? = nil,
        slug: String? = nil,
        releaseYear: Int? = nil
    ) {
        self.igdbId = igdbId
        self.title = title
        self.coverImageId = coverImageId
        self.slug = slug
        self.releaseYear = releaseYear
    }

    /// URL de la jaquette pour une taille donnée, ou `nil` si absente.
    func coverURL(size: IGDBImageSize = .coverBig) -> URL? {
        coverImageId.flatMap { size.url(imageId: $0) }
    }

    // MARK: Médias

    /// Image du bandeau d'en-tête : une capture en priorité, à défaut une
    /// illustration.
    ///
    /// Les captures IGDB sont toujours en 16:9 et montrent le jeu ; les
    /// illustrations ont des ratios variables et sont souvent un logo sur fond
    /// clair, qui jure avec les thèmes sombres de l'app.
    var heroImageId: String? {
        screenshotImageIds.first ?? artworkImageIds.first
    }

    /// Remplace les médias du jeu et date la récupération.
    func apply(_ media: IGDBGameMedia) {
        screenshotImageIds = media.screenshotImageIds
        artworkImageIds = media.artworkImageIds
        mediaFetchedAt = Date()
    }
}
