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
    /// Bloc tout juste créé : le sélecteur s'ouvre sans action de l'utilisateur.
    var autoPresentPicker: Bool = false
    var onPickerPresented: () -> Void = {}

    @EnvironmentObject private var localization: LocalizationManager
    @Environment(\.theme) private var theme

    @State private var content = PhotoContent()
    @State private var pickerItems: [PhotosPickerItem] = []
    @State private var isPickerPresented = false
    /// Photo affichée en plein écran (QuickLook), parmi `photoURLs`.
    @State private var previewURL: URL?

    private let columns = [GridItem(.adaptive(minimum: 90), spacing: Theme.Spacing.small)]

    /// URLs locales de toutes les photos du bloc (pour le swipe QuickLook).
    private var photoURLs: [URL] {
        content.fileNames.map { ImageStore.url(for: $0) }
    }

    var body: some View {
        // Capturée hors du closure (non-isolé) du label de PhotosPicker.
        let addLabel = localization.string(.photoAdd)

        return VStack(alignment: .leading, spacing: Theme.Spacing.small) {
            if !content.fileNames.isEmpty {
                LazyVGrid(columns: columns, spacing: Theme.Spacing.small) {
                    ForEach(content.fileNames, id: \.self) { fileName in
                        thumbnail(fileName)
                    }
                }
            }

            PhotosPicker(
                selection: $pickerItems,
                maxSelectionCount: 10,
                matching: .images
            ) {
                Label(addLabel, systemImage: "photo.on.rectangle")
                    .font(.system(size: Theme.FontSize.caption, weight: .semibold))
                    .foregroundStyle(theme.accent)
            }
        }
        .padding(Theme.Spacing.medium)
        .background(
            RoundedRectangle(cornerRadius: Theme.Radius.medium, style: .continuous)
                .fill(theme.surface.opacity(0.4))
        )
        .photosPicker(
            isPresented: $isPickerPresented,
            selection: $pickerItems,
            maxSelectionCount: 10,
            matching: .images
        )
        .onAppear {
            content = block.photos
            guard autoPresentPicker else { return }
            onPickerPresented()
            isPickerPresented = true
        }
        .onChange(of: pickerItems) { _, items in
            guard !items.isEmpty else { return }
            importPickerItems(items)
        }
        .quickLookPreview($previewURL, in: photoURLs)
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
        .frame(width: 90, height: 90)
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
