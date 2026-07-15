//
//  WikiDetailView.swift
//  Grym
//
//  Détail d'un wiki : en-tête, note personnelle (slider) et pages.
//  Utilise `@Bindable` sur le modèle SwiftData (idiome recommandé pour
//  l'édition directe : écart MVVM justifié). Les mutations structurelles
//  passent par `WikiRepository`.
//

import SwiftData
import SwiftUI

struct WikiDetailView: View {
    @Bindable var wiki: Wiki

    @EnvironmentObject private var localization: LocalizationManager
    @Environment(\.theme) private var theme
    @Environment(\.modelContext) private var modelContext

    private var repository: WikiRepository { WikiRepository(context: modelContext) }

    /// Palette d'accents cyclée pour différencier visuellement les pages.
    private let pageAccents: [Color] = [.grymAccent, .grymAccentViolet, .grymAccentRose, .grymAccentGreen]

    private var sortedPages: [Page] {
        wiki.pages.sorted { $0.order < $1.order }
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: Theme.Spacing.large) {
                WikiDetailHeader(
                    title: wiki.game?.title ?? "",
                    coverURL: wiki.game?.coverURL(size: .coverBig),
                    coverTint: .grymTint(for: wiki.game?.title ?? ""),
                    metaLine: metaLine,
                    blockCount: wiki.blockCount,
                    photoCount: wiki.photoCount,
                    listCount: wiki.listCount,
                    updatedAt: wiki.updatedAt,
                    isPinned: wiki.isPinned,
                    onTogglePin: togglePin
                )

                WikiScoreCard(score: $wiki.score, onCommit: { repository.touch(wiki) })

                pagesSection
            }
            .padding(.horizontal, Theme.Spacing.large)
            .padding(.top, Theme.Spacing.small)
            .padding(.bottom, Theme.Spacing.xLarge)
        }
        .background(background)
        .navigationTitle(wiki.game?.title ?? "")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: Pages

    private var pagesSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.medium) {
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

            ForEach(Array(sortedPages.enumerated()), id: \.element.persistentModelID) { index, page in
                PageRowView(
                    title: page.title,
                    blockCount: page.blocks.count,
                    accent: pageAccents[index % pageAccents.count]
                )
            }
        }
    }

    // MARK: Actions

    private func togglePin() {
        wiki.isPinned.toggle()
        repository.touch(wiki)
    }

    private func addPage() {
        _ = try? repository.addPage(to: wiki, title: localization.string(.wikiNewPageDefaultTitle))
    }

    private var metaLine: String? {
        guard let game = wiki.game else { return nil }
        let parts = [game.releaseYear.map(String.init), game.platform].compactMap { $0 }
        return parts.isEmpty ? nil : parts.joined(separator: " · ")
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
    .environment(\.theme, GrymBlueTheme())
}
