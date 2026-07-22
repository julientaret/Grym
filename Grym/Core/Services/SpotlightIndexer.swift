//
//  SpotlightIndexer.swift
//  Grym
//
//  Indexation CoreSpotlight de la collection : chaque jeu et chaque wiki
//  devient consultable depuis la recherche système d'iOS.
//  Les identifiants sont lisibles et reconstruits depuis SwiftData
//  (`game:<igdbId>` / `page:<igdbId>:<titre>`), pour rester valides même
//  si le store est recréé.
//

// `@preconcurrency` : CoreSpotlight n'annote pas encore ses types Sendable,
// et l'indexation reste confinée au MainActor.
@preconcurrency import CoreSpotlight
import Foundation
import SwiftData

@MainActor
enum SpotlightIndexer {

    /// Domaine des éléments indexés (permet un effacement global).
    private static let domain = "com.applemousse.grym.library"
    private static let gamePrefix = "game"
    private static let pagePrefix = "page"

    /// Réindexe toute la collection. Appelé au lancement et aux passages
    /// en arrière-plan : le corpus est local et de taille modeste.
    static func reindexAll(context: ModelContext) {
        guard CSSearchableIndex.isIndexingAvailable() else { return }

        let wikis = (try? context.fetch(FetchDescriptor<Wiki>())) ?? []
        var items: [CSSearchableItem] = []

        for wiki in wikis {
            guard let game = wiki.game else { continue }

            items.append(makeItem(
                id: "\(gamePrefix):\(game.igdbId)",
                title: game.title,
                description: game.releaseYear.map(String.init) ?? "",
                keywords: [game.title]
            ))

            for page in wiki.pages {
                items.append(makeItem(
                    id: "\(pagePrefix):\(game.igdbId):\(page.title)",
                    title: page.title,
                    description: game.title,
                    keywords: [game.title, page.title]
                ))
            }
        }

        let index = CSSearchableIndex.default()
        index.deleteSearchableItems(withDomainIdentifiers: [domain]) { _ in
            index.indexSearchableItems(items) { _ in }
        }
    }

    /// Résout l'élément Spotlight sélectionné en destination applicative.
    static func target(for identifier: String, context: ModelContext) -> ActivityTarget? {
        let parts = identifier.split(separator: ":", maxSplits: 2).map(String.init)
        guard parts.count >= 2, let igdbId = Int(parts[1]) else { return nil }

        let descriptor = FetchDescriptor<Wiki>()
        guard let wiki = (try? context.fetch(descriptor))?
            .first(where: { $0.game?.igdbId == igdbId }) else { return nil }

        let page = parts.count == 3 ? wiki.page(titled: parts[2]) : nil
        return ActivityTarget(wiki: wiki, page: page)
    }

    // MARK: Privé

    private static func makeItem(
        id: String,
        title: String,
        description: String,
        keywords: [String]
    ) -> CSSearchableItem {
        let attributes = CSSearchableItemAttributeSet(contentType: .content)
        attributes.title = title
        attributes.contentDescription = description
        attributes.keywords = keywords

        return CSSearchableItem(
            uniqueIdentifier: id,
            domainIdentifier: domain,
            attributeSet: attributes
        )
    }
}
