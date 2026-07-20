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

    private static let hour: TimeInterval = 3600
    private static let day: TimeInterval = 86_400

    /// Conteneur en mémoire seedé avec quelques wikis représentatifs.
    static let container: ModelContainer = {
        // force try / force unwrap justifiés : code de preview DEBUG uniquement.
        let container = try! ModelContainer(
            for: Game.self, Wiki.self, Page.self, Block.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let context = container.mainContext

        // Médias : `image_id` réels d'IGDB, pour que les previews du bandeau et
        // de la galerie chargent de vraies images. Les deux autres jeux sont
        // volontairement laissés sans médias (état « jeu sans illustration »).
        seed(context, igdbId: 1, title: "Elden Ring", cover: "co4jni",
             year: 2022, score: 92, pinned: true,
             photos: 18, lists: 9, texts: 36, age: 2 * hour,
             artworks: ["ar3m1o", "ar3m1p", "ar1481"],
             screenshots: ["scagdm", "scagdn", "scagdo", "scagdp", "scagdq"])
        seed(context, igdbId: 2, title: "Baldur's Gate 3", cover: "co670h",
             year: 2023, score: 88, pinned: true,
             photos: 11, lists: 7, texts: 24, age: day)
        seed(context, igdbId: 3, title: "Subnautica", cover: "co1o6r",
             year: 2018, score: 76, pinned: false,
             photos: 24, lists: 5, texts: 18, age: 3 * day)

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

    /// Première page du premier wiki (pour les previews d'éditeur).
    static var samplePage: Page {
        // force unwrap justifié : code de preview DEBUG uniquement.
        sampleWiki.pages.first!
    }

    /// `age` : ancienneté de la création du wiki et de sa note, pour que les
    /// previews du flux d'activité affichent des dates relatives crédibles.
    private static func seed(
        _ context: ModelContext,
        igdbId: Int, title: String, cover: String,
        year: Int, score: Int, pinned: Bool,
        photos: Int, lists: Int, texts: Int, age: TimeInterval,
        artworks: [String] = [], screenshots: [String] = []
    ) {
        let date = Date().addingTimeInterval(-age)
        let game = Game(igdbId: igdbId, title: title, coverImageId: cover,
                        releaseYear: year)
        if !artworks.isEmpty || !screenshots.isEmpty {
            game.apply(IGDBGameMedia(screenshotImageIds: screenshots, artworkImageIds: artworks))
        }
        context.insert(game)

        let wiki = Wiki(game: game, score: score, isPinned: pinned)
        wiki.scoreUpdatedAt = date
        context.insert(wiki)

        let page = Page(title: "Notes", order: 0, createdAt: date)
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
