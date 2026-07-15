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
        List {
            TextField(localization.string(.pageTitlePlaceholder), text: $page.title)
                .font(.system(size: Theme.FontSize.title, weight: .bold))
                .foregroundStyle(theme.primaryText)
                .grymBlockRow()

            if sortedBlocks.isEmpty {
                emptyState.grymBlockRow()
            } else {
                ForEach(sortedBlocks) { block in
                    blockView(block).grymBlockRow()
                }
                .onMove(perform: moveBlocks)
                .onDelete(perform: deleteBlocks)
            }

            AddBlockButton { type in
                _ = try? repository.addBlock(to: page, type: type)
            }
            .grymBlockRow()
        }
        .listStyle(.plain)
        .environment(\.defaultMinListRowHeight, 0)
        .scrollContentBackground(.hidden)
        .background(background)
        .navigationTitle(page.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) { EditButton() }
        }
        .onDisappear { repository.save() }
    }

    // MARK: Réorganisation / suppression

    private func moveBlocks(from source: IndexSet, to destination: Int) {
        var blocks = sortedBlocks
        blocks.move(fromOffsets: source, toOffset: destination)
        for (index, block) in blocks.enumerated() { block.order = index }
        repository.save()
    }

    private func deleteBlocks(at offsets: IndexSet) {
        for index in offsets { try? repository.delete(sortedBlocks[index]) }
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
