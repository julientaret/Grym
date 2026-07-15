//
//  WikiRepository.swift
//  Grym
//
//  Opérations d'écriture sur les wikis (création, suppression) autour
//  d'un `ModelContext`. Garde la logique de persistance hors des vues.
//

import Foundation
import SwiftData

@MainActor
struct WikiRepository {
    let context: ModelContext

    /// Crée (ou récupère) le wiki d'un jeu IGDB.
    /// Dé-doublonne : réutilise le `Game` existant (même `igdbId`) et son wiki.
    @discardableResult
    func addWiki(for igdbGame: IGDBGame) throws -> Wiki {
        let igdbId = igdbGame.id

        // Jeu déjà présent ? → réutiliser son wiki, ou en créer un.
        let descriptor = FetchDescriptor<Game>(
            predicate: #Predicate { $0.igdbId == igdbId }
        )
        if let existingGame = try context.fetch(descriptor).first {
            if let wiki = existingGame.wikis.first { return wiki }
            return try makeWiki(for: existingGame)
        }

        // Nouveau jeu.
        let game = Game(
            igdbId: igdbGame.id,
            title: igdbGame.name,
            coverImageId: igdbGame.cover?.imageId,
            slug: igdbGame.slug,
            platform: igdbGame.primaryPlatform,
            releaseYear: igdbGame.releaseYear
        )
        context.insert(game)
        return try makeWiki(for: game)
    }

    /// Supprime un wiki (et son contenu en cascade).
    func delete(_ wiki: Wiki) throws {
        context.delete(wiki)
        try context.save()
    }

    /// Ajoute une page au wiki (ordre = fin de liste) et sauvegarde.
    @discardableResult
    func addPage(to wiki: Wiki, title: String) throws -> Page {
        let order = (wiki.pages.map(\.order).max() ?? -1) + 1
        let page = Page(title: title, order: order)
        page.wiki = wiki
        context.insert(page)
        wiki.updatedAt = Date()
        try context.save()
        return page
    }

    /// Marque le wiki comme modifié et persiste (après édition de score/épinglage).
    func touch(_ wiki: Wiki) {
        wiki.updatedAt = Date()
        try? context.save()
    }

    /// Ajoute un bloc à une page (ordre = fin de liste) et sauvegarde.
    @discardableResult
    func addBlock(to page: Page, type: BlockType, content: String = "") throws -> Block {
        let order = (page.blocks.map(\.order).max() ?? -1) + 1
        let block = Block(type: type, content: content, order: order)
        block.page = page
        context.insert(block)
        page.wiki?.updatedAt = Date()
        try context.save()
        return block
    }

    /// Supprime un bloc et sauvegarde.
    func delete(_ block: Block) throws {
        block.page?.wiki?.updatedAt = Date()
        context.delete(block)
        try context.save()
    }

    /// Persiste les modifications en cours (édition inline de blocs/titres).
    func save() {
        try? context.save()
    }

    // MARK: Privé

    private func makeWiki(for game: Game) throws -> Wiki {
        let wiki = Wiki(game: game)
        context.insert(wiki)
        try context.save()
        return wiki
    }
}
