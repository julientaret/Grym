//
//  WikiDetailView.swift
//  Grym
//
//  Détail d'un wiki : bandeau illustré, en-tête, note personnelle (slider),
//  galerie des photos de l'utilisateur et pages.
//  Utilise `@Bindable` sur le modèle SwiftData (idiome recommandé pour
//  l'édition directe : écart MVVM justifié). Les mutations structurelles
//  passent par `WikiRepository`.
//

import QuickLook
import SwiftData
import SwiftUI

struct WikiDetailView: View {
    @Bindable var wiki: Wiki

    @EnvironmentObject private var localization: LocalizationManager
    @EnvironmentObject private var preferences: PreferencesManager
    @Environment(\.theme) private var theme
    @Environment(\.modelContext) private var modelContext

    @StateObject private var mediaViewModel = WikiMediaViewModel()

    @State private var selectedPageID: PersistentIdentifier?
    @State private var openPage: Page?
    /// Page tout juste créée : son titre prendra le focus à l'ouverture.
    @State private var createdPageID: PersistentIdentifier?
    /// Photo affichée en plein écran (QuickLook), parmi `photoURLs`.
    @State private var previewURL: URL?

    private var repository: WikiRepository { WikiRepository(context: modelContext) }

    private let gridColumns = [
        GridItem(.flexible(), spacing: Theme.Spacing.medium),
        GridItem(.flexible(), spacing: Theme.Spacing.medium)
    ]


    private var sortedPages: [Page] {
        wiki.pages.sorted { $0.order < $1.order }
    }

    var body: some View {
        List {
            if let heroImageId = wiki.game?.heroImageId {
                WikiHeroBanner(imageId: heroImageId, tint: coverTint)
                    .grymFullWidthRow()
            }

            WikiDetailHeader(
                title: wiki.game?.title ?? "",
                coverImageId: wiki.game?.coverImageId,
                coverTint: coverTint,
                metaLine: metaLine,
                blockCount: wiki.blockCount,
                photoCount: wiki.photoCount,
                listCount: wiki.listCount,
                updatedAt: wiki.updatedAt,
                isPinned: wiki.isPinned,
                onTogglePin: togglePin
            )
            .grymBlockRow()

            WikiScoreCard(score: $wiki.score, onCommit: { repository.updateScore(wiki) })
                .grymBlockRow()

            if !photoFileNames.isEmpty {
                WikiMediaGallery(fileNames: photoFileNames, onOpen: { previewURL = ImageStore.url(for: $0) })
                    .grymFullWidthRow()
            }

            pagesHeader.grymBlockRow()

            pagesContent
        }
        .listStyle(.plain)
        .environment(\.defaultMinListRowHeight, 0)
        .scrollContentBackground(.hidden)
        .background(background)
        // Le bandeau doit filer jusqu'au haut de l'écran, la barre de navigation
        // se posant par-dessus. Sans bandeau, la liste garde sa marge normale.
        .ignoresSafeArea(edges: hasHero ? .top : [])
        .navigationTitle(wiki.game?.title ?? "")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if preferences.wikiPagesMode == .list {
                ToolbarItem(placement: .topBarTrailing) { EditButton() }
            }
        }
        .navigationDestination(item: $openPage) { page in
            PageDetailView(page: page, autofocusTitle: page.persistentModelID == createdPageID)
        }
        .quickLookPreview($previewURL, in: photoURLs)
        .task(id: wiki.game?.igdbId) {
            await mediaViewModel.loadIfNeeded(for: wiki.game, context: modelContext)
        }
    }

    // MARK: Médias

    private var coverTint: Color {
        .grymTint(for: wiki.game?.title ?? "")
    }

    /// Photos ajoutées par l'utilisateur dans les blocs photo du wiki.
    private var photoFileNames: [String] {
        wiki.photoFileNames
    }

    /// URLs locales de toutes les photos (pour le swipe QuickLook).
    private var photoURLs: [URL] {
        photoFileNames.map { ImageStore.url(for: $0) }
    }

    private var hasHero: Bool {
        wiki.game?.heroImageId != nil
    }

    // MARK: Pages

    @ViewBuilder
    private var pagesContent: some View {
        switch preferences.wikiPagesMode {
        case .list:
            ForEach(sortedPages) { page in
                Button { openPage = page } label: {
                    PageRowView(
                        title: page.title,
                        blockCount: page.blocks.count,
                        accent: accent(for: page)
                    )
                }
                .buttonStyle(.plain)
                .grymBlockRow()
            }
            .onMove(perform: movePages)
            .onDelete(perform: deletePages)

        case .cards:
            LazyVGrid(columns: gridColumns, spacing: Theme.Spacing.medium) {
                ForEach(sortedPages) { page in
                    Button { openPage = page } label: {
                        PageCardView(
                            title: page.title,
                            blockCount: page.blocks.count,
                            accent: accent(for: page)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .grymBlockRow()

        case .tabs:
            PageTabsView(pages: sortedPages, selectedID: $selectedPageID, onOpen: { openPage = $0 })
                .grymBlockRow()
        }
    }

    /// Palette d'accents du thème, cyclée pour différencier les pages.
    private func accent(for page: Page) -> Color {
        let accents = theme.pageAccents
        return accents[abs(page.order) % accents.count]
    }

    private var pagesHeader: some View {
        HStack {
            HStack(spacing: Theme.Spacing.xSmall + 2) {
                Text(localization.string(.wikiPagesTitle))
                    .font(.system(size: Theme.FontSize.body, weight: .semibold))
                    .foregroundStyle(theme.primaryText)
                Text("· \(sortedPages.count)")
                    .font(.system(size: Theme.FontSize.body, weight: .semibold))
                    .foregroundStyle(theme.secondaryText)
            }

            Spacer()

            Button(action: addPage) {
                HStack(spacing: Theme.Spacing.xSmall) {
                    Image(systemName: "plus")
                    Text(localization.string(.wikiNewPage))
                }
                .font(.system(size: Theme.FontSize.caption, weight: .semibold))
                .foregroundStyle(theme.accent)
            }
        }
    }

    private func movePages(from source: IndexSet, to destination: Int) {
        var pages = sortedPages
        pages.move(fromOffsets: source, toOffset: destination)
        for (index, page) in pages.enumerated() { page.order = index }
        repository.save()
    }

    private func deletePages(at offsets: IndexSet) {
        for index in offsets {
            let page = sortedPages[index]
            modelContext.delete(page)
        }
        repository.save()
    }

    // MARK: Actions

    private func togglePin() {
        wiki.isPinned.toggle()
        repository.touch(wiki)
    }

    /// Crée la page puis l'ouvre immédiatement.
    private func addPage() {
        guard let page = try? repository.addPage(
            to: wiki,
            title: localization.string(.wikiNewPageDefaultTitle)
        ) else { return }
        createdPageID = page.persistentModelID
        openPage = page
    }

    private var metaLine: String? {
        guard let game = wiki.game else { return nil }
        return game.releaseYear.map(String.init)
    }

    // MARK: Fond

    private var background: some View {
        ZStack {
            LinearGradient(
                colors: [theme.backgroundDeep, theme.background],
                startPoint: .top, endPoint: .bottom
            )
            RadialGradient(
                colors: [theme.glow.opacity(0.5), .clear],
                center: UnitPoint(x: 0.5, y: 0.0),
                startRadius: 4, endRadius: 320
            )
        }
        .ignoresSafeArea()
    }
}

#Preview {
    NavigationStack {
        WikiDetailView(wiki: PreviewSampleData.sampleWiki)
    }
    .modelContainer(PreviewSampleData.container)
    .environmentObject(LocalizationManager())
    .environmentObject(PreferencesManager())
    .environment(\.theme, GrymBlueTheme())
}
