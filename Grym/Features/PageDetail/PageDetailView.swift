//
//  PageDetailView.swift
//  Grym
//
//  Éditeur d'une page : titre éditable et flux de blocs (texte, checklist).
//  Édition directe du modèle via `@Bindable` ; structure via `WikiRepository`.
//

import SwiftData
import SwiftUI

struct PageDetailView: View {
    @Bindable var page: Page

    @EnvironmentObject private var localization: LocalizationManager
    @Environment(\.theme) private var theme
    @Environment(\.modelContext) private var modelContext

    private var repository: WikiRepository { WikiRepository(context: modelContext) }

    private var sortedBlocks: [Block] {
        page.blocks.sorted { $0.order < $1.order }
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: Theme.Spacing.large) {
                TextField(localization.string(.pageTitlePlaceholder), text: $page.title)
                    .font(.system(size: Theme.FontSize.title, weight: .bold))
                    .foregroundStyle(theme.primaryText)

                if sortedBlocks.isEmpty {
                    emptyState
                } else {
                    ForEach(sortedBlocks) { block in
                        blockView(block)
                            .contextMenu {
                                Button(role: .destructive) {
                                    try? repository.delete(block)
                                } label: {
                                    Label(localization.string(.commonDelete), systemImage: "trash")
                                }
                            }
                    }
                }

                AddBlockButton { type in
                    _ = try? repository.addBlock(to: page, type: type)
                }
            }
            .padding(.horizontal, Theme.Spacing.large)
            .padding(.top, Theme.Spacing.small)
            .padding(.bottom, Theme.Spacing.xLarge)
        }
        .background(background)
        .navigationTitle(page.title)
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear { repository.save() }
    }

    // MARK: Rendu d'un bloc

    @ViewBuilder
    private func blockView(_ block: Block) -> some View {
        switch block.type {
        case .text:
            TextBlockView(block: block)
        case .checklist:
            ChecklistBlockView(block: block)
        case .photo:
            PhotoBlockView(block: block)
        case .map:
            MapBlockView(block: block)
        }
    }

    // MARK: État vide

    private var emptyState: some View {
        VStack(spacing: Theme.Spacing.medium) {
            Image(systemName: "square.stack")
                .font(.system(size: Theme.FontSize.largeTitle))
                .foregroundStyle(theme.secondaryText.opacity(0.7))
            Text(localization.string(.pageEmptyBlocks))
                .font(.system(size: Theme.FontSize.body))
                .foregroundStyle(theme.secondaryText)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Theme.Spacing.large)
    }

    // MARK: Fond

    private var background: some View {
        LinearGradient(
            colors: [theme.backgroundDeep, theme.background],
            startPoint: .top, endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}

#Preview {
    NavigationStack {
        PageDetailView(page: PreviewSampleData.samplePage)
    }
    .modelContainer(PreviewSampleData.container)
    .environmentObject(LocalizationManager())
    .environment(\.theme, GrymBlueTheme())
}
