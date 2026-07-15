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
    var photoCount: Int { allBlocks.filter { $0.type == .photo }.count }
    var listCount: Int { allBlocks.filter { $0.type == .checklist }.count }
}
