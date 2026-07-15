//
//  HomeModel.swift
//  Grym
//
//  Modèles de présentation de l'écran d'accueil (Wikis).
//  Temporaire : alimentés par des données mockées tant que la couche
//  SwiftData (Game / Wiki / Page / Block) n'est pas branchée.
//

import SwiftUI

// MARK: - Wiki (résumé pour la liste)

/// Résumé d'un wiki tel qu'affiché dans la liste d'accueil.
struct WikiSummary: Identifiable, Hashable {
    let id: UUID
    let title: String
    /// Cover IGDB éventuelle ; à défaut, un dégradé teinté est affiché.
    let coverURL: URL?
    /// Teinte de repli utilisée pour le dégradé de cover.
    let coverTint: Color
    let year: Int?
    let platform: String?
    let blockCount: Int
    let photoCount: Int
    let listCount: Int
    /// Note personnelle privée (0–100).
    let score: Int
    let updatedAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        coverURL: URL? = nil,
        coverTint: Color,
        year: Int?,
        platform: String?,
        blockCount: Int,
        photoCount: Int,
        listCount: Int,
        score: Int,
        updatedAt: Date
    ) {
        self.id = id
        self.title = title
        self.coverURL = coverURL
        self.coverTint = coverTint
        self.year = year
        self.platform = platform
        self.blockCount = blockCount
        self.photoCount = photoCount
        self.listCount = listCount
        self.score = score
        self.updatedAt = updatedAt
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
    let coverTint: Color
    let date: Date

    init(
        id: UUID = UUID(),
        kind: ActivityKind,
        title: String,
        subtitle: String,
        coverTint: Color,
        date: Date
    ) {
        self.id = id
        self.kind = kind
        self.title = title
        self.subtitle = subtitle
        self.coverTint = coverTint
        self.date = date
    }
}
