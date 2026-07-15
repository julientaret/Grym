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
    var platform: String?
    var releaseYear: Int?

    /// Wikis rattachés à ce jeu (supprimés en cascade avec le jeu).
    @Relationship(deleteRule: .cascade, inverse: \Wiki.game)
    var wikis: [Wiki] = []

    init(
        igdbId: Int,
        title: String,
        coverImageId: String? = nil,
        slug: String? = nil,
        platform: String? = nil,
        releaseYear: Int? = nil
    ) {
        self.igdbId = igdbId
        self.title = title
        self.coverImageId = coverImageId
        self.slug = slug
        self.platform = platform
        self.releaseYear = releaseYear
    }

    /// URL de la jaquette pour une taille donnée, ou `nil` si absente.
    func coverURL(size: IGDBImageSize = .coverBig) -> URL? {
        coverImageId.flatMap { size.url(imageId: $0) }
    }
}
