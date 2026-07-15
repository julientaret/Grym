//
//  PreviewSampleData.swift
//  Grym
//
//  Conteneur SwiftData en mémoire, pré-rempli, pour les previews SwiftUI.
//

#if DEBUG
import Foundation
import SwiftData

@MainActor
enum PreviewSampleData {

    /// Conteneur en mémoire seedé avec quelques wikis représentatifs.
    static let container: ModelContainer = {
        // force try / force unwrap justifiés : code de preview DEBUG uniquement.
        let container = try! ModelContainer(
            for: Game.self, Wiki.self, Page.self, Block.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let context = container.mainContext

        seed(context, igdbId: 1, title: "Elden Ring", cover: "co4jni",
             platform: "PS5", year: 2022, score: 92, pinned: true,
             photos: 18, lists: 9, texts: 36)
        seed(context, igdbId: 2, title: "Baldur's Gate 3", cover: "co670h",
             platform: "PC", year: 2023, score: 88, pinned: true,
             photos: 11, lists: 7, texts: 24)
        seed(context, igdbId: 3, title: "Subnautica", cover: "co1o6r",
             platform: "PC", year: 2018, score: 76, pinned: false,
             photos: 24, lists: 5, texts: 18)

        return container
    }()

    /// Premier wiki du conteneur (pour les previews de détail).
    static var sampleWiki: Wiki {
        // force try / force unwrap justifiés : code de preview DEBUG uniquement.
        let descriptor = FetchDescriptor<Wiki>(
            sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
        )
        return try! container.mainContext.fetch(descriptor).first!
    }

    private static func seed(
        _ context: ModelContext,
        igdbId: Int, title: String, cover: String,
        platform: String, year: Int, score: Int, pinned: Bool,
        photos: Int, lists: Int, texts: Int
    ) {
        let game = Game(igdbId: igdbId, title: title, coverImageId: cover,
                        platform: platform, releaseYear: year)
        context.insert(game)

        let wiki = Wiki(game: game, score: score, isPinned: pinned)
        context.insert(wiki)

        let page = Page(title: "Notes", order: 0)
        page.wiki = wiki
        context.insert(page)

        var order = 0
        func addBlocks(_ count: Int, _ type: BlockType) {
            for _ in 0..<count {
                let block = Block(type: type, content: "", order: order)
                block.page = page
                context.insert(block)
                order += 1
            }
        }
        addBlocks(texts, .text)
        addBlocks(photos, .photo)
        addBlocks(lists, .checklist)
    }
}
#endif
