//
//  Wiki.swift
//  Grym
//
//  Wiki personnel d'un jeu : note privée, pages, épinglage.
//

import Foundation
import SwiftData

@Model
final class Wiki {
    var game: Game?
    var userId: String?
    /// Note personnelle privée (0–100), jamais partagée.
    var score: Int
    var isPublic: Bool
    var isPinned: Bool
    var createdAt: Date
    var updatedAt: Date
    /// Dernier changement de note personnelle ; `nil` tant qu'aucune note n'a
    /// été donnée (alimente le flux d'activité de l'accueil).
    var scoreUpdatedAt: Date?

    /// Pages du wiki (supprimées en cascade).
    @Relationship(deleteRule: .cascade, inverse: \Page.wiki)
    var pages: [Page] = []

    init(
        game: Game,
        score: Int = 0,
        isPublic: Bool = false,
        isPinned: Bool = false,
        userId: String? = nil
    ) {
        self.game = game
        self.score = score
        self.isPublic = isPublic
        self.isPinned = isPinned
        self.userId = userId
        let now = Date()
        self.createdAt = now
        self.updatedAt = now
    }
}

// MARK: - Statistiques dérivées

extension Wiki {
    /// Tous les blocs, toutes pages confondues.
    var allBlocks: [Block] { pages.flatMap(\.blocks) }

    var blockCount: Int { allBlocks.count }

    /// Fichiers de toutes les photos du wiki (cf. `ImageStore`), dans l'ordre de
    /// lecture : pages puis blocs. Alimente la galerie du détail.
    var photoFileNames: [String] {
        pages.sorted { $0.order < $1.order }
            .flatMap { $0.blocks.sorted { $0.order < $1.order } }
            .filter { $0.type == .photo }
            .flatMap { $0.photos.fileNames }
    }

    /// Nombre total d'images (un bloc photo peut en contenir plusieurs).
    var photoCount: Int { photoFileNames.count }
    var listCount: Int { allBlocks.filter { $0.type == .checklist }.count }
}
