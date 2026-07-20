//
//  HomeModel.swift
//  Grym
//
//  Modèles de présentation de l'écran d'accueil, construits à partir de
//  la couche SwiftData (Game / Wiki / Page / Block).
//

import SwiftData
import SwiftUI

// MARK: - Wiki (résumé pour la liste)

/// Résumé d'un wiki tel qu'affiché dans la liste d'accueil.
struct WikiSummary: Identifiable, Hashable {
    let id: String
    let title: String
    /// `image_id` IGDB de la jaquette ; à défaut, un dégradé teinté est affiché.
    let coverImageId: String?
    /// Teinte de repli utilisée pour le dégradé de cover.
    let coverTint: Color
    let year: Int?
    let blockCount: Int
    let photoCount: Int
    let listCount: Int
    /// Note personnelle privée (0–100).
    let score: Int
    let updatedAt: Date

    init(
        id: String = UUID().uuidString,
        title: String,
        coverImageId: String? = nil,
        coverTint: Color,
        year: Int?,
        blockCount: Int,
        photoCount: Int,
        listCount: Int,
        score: Int,
        updatedAt: Date
    ) {
        self.id = id
        self.title = title
        self.coverImageId = coverImageId
        self.coverTint = coverTint
        self.year = year
        self.blockCount = blockCount
        self.photoCount = photoCount
        self.listCount = listCount
        self.score = score
        self.updatedAt = updatedAt
    }

    /// Construit un résumé à partir d'un wiki persistant (SwiftData).
    /// Retourne `nil` si le wiki n'a pas de jeu rattaché.
    init?(wiki: Wiki) {
        guard let game = wiki.game else { return nil }
        self.init(
            id: "\(game.igdbId)",
            title: game.title,
            coverImageId: game.coverImageId,
            coverTint: .grymTint(for: game.title),
            year: game.releaseYear,
            blockCount: wiki.blockCount,
            photoCount: wiki.photoCount,
            listCount: wiki.listCount,
            score: wiki.score,
            updatedAt: wiki.updatedAt
        )
    }
}

// MARK: - Activité récente

/// Nature d'une entrée d'activité (détermine icône et libellé).
enum ActivityKind {
    case checklist
    case photos
    case page
    case note

    /// Symbole SF associé.
    var systemImage: String {
        switch self {
        case .checklist: "checklist"
        case .photos:    "photo.on.rectangle"
        case .page:      "book.pages"
        case .note:      "note.text"
        }
    }
}

/// Une entrée du flux « Activité récente ».
struct ActivityEntry: Identifiable, Hashable {
    let id: UUID
    let kind: ActivityKind
    /// Titre de l'action (ex. « Added checklist »).
    let title: String
    /// Sous-titre contextuel (ex. « Elden Ring · Remembrance Bosses »).
    let subtitle: String
    /// `image_id` IGDB de la jaquette du jeu concerné ; à défaut, dégradé teinté.
    let coverImageId: String?
    let coverTint: Color
    let date: Date
    /// Wiki concerné, cible de la navigation au tap.
    let wikiID: PersistentIdentifier?
    /// Page concernée, ouverte par-dessus le wiki quand l'entrée en vise une.
    let pageID: PersistentIdentifier?

    init(
        id: UUID = UUID(),
        kind: ActivityKind,
        title: String,
        subtitle: String,
        coverImageId: String? = nil,
        coverTint: Color,
        date: Date,
        wikiID: PersistentIdentifier? = nil,
        pageID: PersistentIdentifier? = nil
    ) {
        self.id = id
        self.kind = kind
        self.title = title
        self.subtitle = subtitle
        self.coverImageId = coverImageId
        self.coverTint = coverTint
        self.date = date
        self.wikiID = wikiID
        self.pageID = pageID
    }
}

// MARK: - Cible de navigation d'une activité

/// Destination d'une entrée d'activité : un wiki, éventuellement ouvert
/// directement sur une de ses pages.
struct ActivityTarget: Hashable {
    let wiki: Wiki
    let page: Page?
}
