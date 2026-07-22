//
//  PageDetailView.swift
//  Grym
//
//  Éditeur d'une page : titre éditable, flux de blocs (texte, checklist,
//  photo, carte) et rétroliens. Édition directe du modèle via `@Bindable` ;
//  structure via `WikiRepository`.
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
    /// Bloc photo/carte tout juste ajouté : sa vue ouvre directement le
    /// sélecteur d'images, puis remet cette valeur à `nil`.
    @State private var pendingPickerBlockID: PersistentIdentifier?
    /// Page ouverte par un lien interne ou un rétrolien.
    @State private var linkedPage: Page?

    private var repository: WikiRepository { WikiRepository(context: modelContext) }

    private var sortedBlocks: [Block] {
        page.blocks.sorted { $0.order < $1.order }
    }

    var body: some View {
        List {
            TextField(localization.string(.pageTitlePlaceholder), text: $page.title)
                .font(.system(size: Theme.FontSize.title, weight: .bold))
                .foregroundStyle(theme.primaryText)
                .focused($isTitleFocused)
                .submitLabel(.done)
                .grymBlockRow()

            if sortedBlocks.isEmpty {
                EmptyBlocksPlaceholder().grymBlockRow()
            } else {
                ForEach(sortedBlocks) { block in
                    blockView(block).grymBlockRow()
                }
                .onMove(perform: moveBlocks)
                .onDelete(perform: deleteBlocks)
            }

            AddBlockButton { type in
                guard let block = try? repository.addBlock(to: page, type: type) else { return }
                if type == .photo || type == .map {
                    pendingPickerBlockID = block.persistentModelID
                }
            }
            .grymBlockRow()

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
    private func blockView(_ block: Block) -> some View {
        switch block.type {
        case .text:
            TextBlockView(block: block, wiki: page.wiki, onOpenLink: openLink)
        case .checklist:
            ChecklistBlockView(block: block)
        case .photo:
            PhotoBlockView(
                block: block,
                autoPresentPicker: isPendingPicker(block),
                onPickerPresented: { pendingPickerBlockID = nil }
            )
        case .map:
            MapBlockView(
                block: block,
                autoPresentPicker: isPendingPicker(block),
                onPickerPresented: { pendingPickerBlockID = nil }
            )
        }
    }

    private func isPendingPicker(_ block: Block) -> Bool {
        block.persistentModelID == pendingPickerBlockID
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
