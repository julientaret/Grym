//
//  PhotoBlockView.swift
//  Grym
//
//  Bloc photo : galerie de miniatures stockées localement, ajout via
//  PhotosPicker (pas de permission requise) et suppression.
//

import PhotosUI
import QuickLook
import SwiftUI

struct PhotoBlockView: View {
    @Bindable var block: Block
    /// Bloc tout juste créé : son nom prend le focus à l'apparition.
    var autofocusTitle: Bool = false
    var onTitleFocused: () -> Void = {}
    var actions: BlockActions?

    @EnvironmentObject private var localization: LocalizationManager
    @Environment(\.theme) private var theme

    @State private var content = PhotoContent()
    @State private var pickerItems: [PhotosPickerItem] = []
    @State private var isPickerPresented = false
    /// Photo affichée en plein écran (QuickLook), parmi `photoURLs`.
    @State private var previewURL: URL?

    private let columns = [GridItem(.adaptive(minimum: Theme.Size.photoThumbnail),
                                   spacing: Theme.Spacing.small)]

    /// URLs locales de toutes les photos du bloc (pour le swipe QuickLook).
    private var photoURLs: [URL] {
        content.fileNames.map { ImageStore.url(for: $0) }
    }

    var body: some View {
        BlockCardView(
            type: .photo,
            title: $block.title,
            autofocusTitle: autofocusTitle,
            onTitleFocused: onTitleFocused,
            onTitleSubmitted: presentPickerIfEmpty,
            actions: actions,
            accessory: { counter },
            content: { grid }
        )
        .photosPicker(
            isPresented: $isPickerPresented,
            selection: $pickerItems,
            maxSelectionCount: 10,
            matching: .images
        )
        .onAppear { content = block.photos }
        .onChange(of: pickerItems) { _, items in
            guard !items.isEmpty else { return }
            importPickerItems(items)
        }
        .quickLookPreview($previewURL, in: photoURLs)
    }

    /// Enchaîne sur le sélecteur une fois le bloc nommé, tant qu'il est vide.
    private func presentPickerIfEmpty() {
        guard content.fileNames.isEmpty else { return }
        isPickerPresented = true
    }

    // MARK: Contenu

    /// Sans photo, une zone d'ajout large ; sinon la grille avec sa tuile « + ».
    @ViewBuilder
    private var grid: some View {
        if content.fileNames.isEmpty {
            emptyDropZone
        } else {
            LazyVGrid(columns: columns, spacing: Theme.Spacing.small) {
                ForEach(content.fileNames, id: \.self) { fileName in
                    thumbnail(fileName)
                }
                addTile
            }
        }
    }

    @ViewBuilder
    private var counter: some View {
        if !content.fileNames.isEmpty {
            Text("\(content.fileNames.count)")
                .font(.system(size: Theme.FontSize.caption, weight: .bold))
                .foregroundStyle(theme.secondaryText)
                .monospacedDigit()
        }
    }

    private var emptyDropZone: some View {
        Button { isPickerPresented = true } label: {
            VStack(spacing: Theme.Spacing.small) {
                Image(systemName: "photo.on.rectangle.angled")
                    .font(.system(size: Theme.FontSize.title))
                Text(localization.string(.photoAdd))
                    .font(.system(size: Theme.FontSize.caption, weight: .semibold))
            }
            .foregroundStyle(BlockType.photo.accent(in: theme))
            .frame(maxWidth: .infinity)
            .padding(.vertical, Theme.Spacing.large)
            .background(
                RoundedRectangle(cornerRadius: Theme.Radius.medium, style: .continuous)
                    .strokeBorder(
                        BlockType.photo.accent(in: theme).opacity(0.35),
                        style: StrokeStyle(lineWidth: 1, dash: [4, 4])
                    )
            )
        }
        .buttonStyle(.plain)
    }

    private var addTile: some View {
        Button { isPickerPresented = true } label: {
            Image(systemName: "plus")
                .font(.system(size: Theme.FontSize.body, weight: .bold))
                .foregroundStyle(BlockType.photo.accent(in: theme))
                .frame(width: Theme.Size.photoThumbnail, height: Theme.Size.photoThumbnail)
                .background(
                    RoundedRectangle(cornerRadius: Theme.Radius.small, style: .continuous)
                        .strokeBorder(
                            BlockType.photo.accent(in: theme).opacity(0.35),
                            style: StrokeStyle(lineWidth: 1, dash: [4, 4])
                        )
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(localization.string(.photoAdd))
    }

    // MARK: Miniature

    private func thumbnail(_ fileName: String) -> some View {
        AsyncImage(url: ImageStore.url(for: fileName)) { phase in
            switch phase {
            case .success(let image):
                image.resizable().scaledToFill()
            default:
                Rectangle().fill(theme.surface.opacity(0.6))
            }
        }
        .frame(width: Theme.Size.photoThumbnail, height: Theme.Size.photoThumbnail)
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.small, style: .continuous))
        .onTapGesture {
            previewURL = ImageStore.url(for: fileName)
        }
        .contextMenu {
            Button(role: .destructive) {
                remove(fileName)
            } label: {
                Label(localization.string(.commonDelete), systemImage: "trash")
            }
        }
    }

    // MARK: Import / suppression

    private func importPickerItems(_ items: [PhotosPickerItem]) {
        Task {
            var names: [String] = []
            for item in items {
                if let data = try? await item.loadTransferable(type: Data.self),
                   let name = ImageStore.save(data) {
                    names.append(name)
                }
            }
            // Mutations du modèle / @State sur le MainActor.
            await MainActor.run {
                content.fileNames.append(contentsOf: names)
                block.photos = content
                pickerItems = []
            }
        }
    }

    private func remove(_ fileName: String) {
        content.fileNames.removeAll { $0 == fileName }
        block.photos = content
        ImageStore.delete(fileName: fileName)
    }
}

#Preview {
    PhotoBlockView(block: Block(type: .photo, content: "", order: 0))
        .padding()
        .background(Color.grymBgDark)
        .environmentObject(LocalizationManager())
        .environment(\.theme, GrymBlueTheme())
}
