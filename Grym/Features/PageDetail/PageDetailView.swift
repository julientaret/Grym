//
//  PageDetailView.swift
//  Grym
//
//  Éditeur d'une page : en-tête (titre + contexte), flux de blocs (texte,
//  checklist, photo, carte), palette d'ajout et rétroliens. Édition directe
//  du modèle via `@Bindable` ; structure via `WikiRepository`.
//

import SwiftData
import SwiftUI

struct PageDetailView: View {
    @Bindable var page: Page
    /// Vrai à l'ouverture d'une page tout juste créée : le titre prend le focus.
    var autofocusTitle: Bool = false

    @EnvironmentObject private var localization: LocalizationManager
    @Environment(\.theme) private var theme
    @Environment(\.modelContext) private var modelContext

    @FocusState private var isTitleFocused: Bool
    /// Armé juste avant la prise de focus du titre, pour n'en sélectionner
    /// le contenu qu'à ce moment-là (et pas sur les champs des blocs).
    @State private var shouldSelectTitle = false
    /// Bloc tout juste ajouté : sa vue met le focus sur le nom — première
    /// chose à saisir — puis remet cette valeur à `nil`.
    @State private var pendingTitleBlockID: PersistentIdentifier?
    /// Page ouverte par un lien interne ou un rétrolien.
    @State private var linkedPage: Page?

    private var repository: WikiRepository { WikiRepository(context: modelContext) }

    private var sortedBlocks: [Block] {
        page.blocks.sorted { $0.order < $1.order }
    }

    var body: some View {
        List {
            PageEditorHeader(
                title: $page.title,
                gameTitle: page.wiki?.game?.title,
                blockCount: page.blocks.count,
                titleFocus: $isTitleFocused
            )
            .grymBlockRow()

            if sortedBlocks.isEmpty {
                EmptyBlocksPlaceholder(onAdd: addBlock).grymBlockRow()
            } else {
                ForEach(Array(sortedBlocks.enumerated()), id: \.element.persistentModelID) { index, block in
                    blockView(block, at: index).grymBlockRow()
                }
                .onMove(perform: moveBlocks)
                .onDelete(perform: deleteBlocks)

                BlockPaletteView(onAdd: addBlock).grymBlockRow()
            }

            if !backlinks.isEmpty {
                PageBacklinksSection(pages: backlinks) { linkedPage = $0 }
                    .grymBlockRow()
            }
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
        .navigationDestination(item: $linkedPage) { page in
            PageDetailView(page: page)
        }
        .onDisappear { repository.save() }
        // Le focus doit attendre la fin de la transition de push, sinon le
        // clavier est refermé aussitôt par l'animation de navigation.
        .task {
            guard autofocusTitle else { return }
            try? await Task.sleep(for: .seconds(Theme.AnimationDuration.medium))
            shouldSelectTitle = true
            isTitleFocused = true
        }
        .selectAllOnFocus(isArmed: $shouldSelectTitle)
    }

    // MARK: Ajout / réorganisation / suppression

    private func addBlock(_ type: BlockType) {
        guard let block = try? repository.addBlock(to: page, type: type) else { return }
        pendingTitleBlockID = block.persistentModelID
    }

    private func moveBlocks(from source: IndexSet, to destination: Int) {
        var blocks = sortedBlocks
        blocks.move(fromOffsets: source, toOffset: destination)
        for (index, block) in blocks.enumerated() { block.order = index }
        repository.save()
    }

    private func deleteBlocks(at offsets: IndexSet) {
        for index in offsets { try? repository.delete(sortedBlocks[index]) }
    }

    /// Actions du menu d'un bloc : déplacement d'un cran et suppression.
    private func actions(at index: Int) -> BlockActions {
        BlockActions(
            canMoveUp: index > 0,
            canMoveDown: index < sortedBlocks.count - 1,
            onMoveUp: { moveBlocks(from: [index], to: index - 1) },
            // `move(fromOffsets:toOffset:)` attend l'index d'insertion,
            // soit deux crans plus loin pour descendre d'une position.
            onMoveDown: { moveBlocks(from: [index], to: index + 2) },
            onDelete: { deleteBlocks(at: [index]) }
        )
    }

    // MARK: Liens internes

    private var backlinks: [Page] { page.backlinks }

    /// Ouvre la page ciblée par un lien `[[Titre]]` ; la crée si elle n'existe
    /// pas encore, pour que le lien reste toujours actionnable.
    private func openLink(to title: String) {
        guard let wiki = page.wiki else { return }
        if let existing = wiki.page(titled: title) {
            linkedPage = existing
        } else {
            repository.save()
            linkedPage = try? repository.addPage(to: wiki, title: title)
        }
    }

    // MARK: Rendu d'un bloc

    @ViewBuilder
    private func blockView(_ block: Block, at index: Int) -> some View {
        let blockActions = actions(at: index)
        let autofocus = block.persistentModelID == pendingTitleBlockID
        let clearPending = { pendingTitleBlockID = nil }

        switch block.type {
        case .text:
            TextBlockView(
                block: block,
                wiki: page.wiki,
                onOpenLink: openLink,
                autofocusTitle: autofocus,
                onTitleFocused: clearPending,
                actions: blockActions
            )
        case .checklist:
            ChecklistBlockView(
                block: block,
                autofocusTitle: autofocus,
                onTitleFocused: clearPending,
                actions: blockActions
            )
        case .photo:
            PhotoBlockView(
                block: block,
                autofocusTitle: autofocus,
                onTitleFocused: clearPending,
                actions: blockActions
            )
        case .map:
            MapBlockView(
                block: block,
                autofocusTitle: autofocus,
                onTitleFocused: clearPending,
                actions: blockActions
            )
        }
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
