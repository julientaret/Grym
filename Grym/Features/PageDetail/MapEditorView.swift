//
//  MapEditorView.swift
//  Grym
//
//  Éditeur plein écran d'une carte annotée : image de fond + pins
//  (ajout au tap, déplacement au drag, renommage/suppression par tap).
//

import PhotosUI
import SwiftUI
import UIKit

struct MapEditorView: View {
    @Bindable var block: Block
    /// Carte tout juste créée : le sélecteur s'ouvre sans action de l'utilisateur.
    var autoPresentPicker: Bool = false

    @EnvironmentObject private var localization: LocalizationManager
    @Environment(\.theme) private var theme
    @Environment(\.dismiss) private var dismiss

    @State private var content = MapContent()
    @State private var image: UIImage?
    @State private var pickerItem: PhotosPickerItem?
    @State private var editingPin: MapPin?
    @State private var editingLabel = ""
    @State private var isPickerPresented = false

    var body: some View {
        // Capturée hors du closure (non-isolé) du label de PhotosPicker.
        let replaceLabel = localization.string(.mapReplaceImage)

        return NavigationStack {
            ScrollView {
                VStack(spacing: Theme.Spacing.medium) {
                    if let image {
                        AnnotatedMapView(
                            image: image,
                            pins: $content.pins,
                            isEditable: true,
                            onTapPin: startEditing
                        )
                        Text(localization.string(.mapEmptyHint))
                            .font(.system(size: Theme.FontSize.caption))
                            .foregroundStyle(theme.secondaryText)
                    } else {
                        imagePicker
                    }
                }
                .padding(Theme.Spacing.large)
            }
            .background(background)
            .navigationTitle(localization.string(.blockTypeMap))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(localization.string(.commonDone)) { dismiss() }
                }
                if image != nil {
                    ToolbarItem(placement: .topBarLeading) {
                        PhotosPicker(selection: $pickerItem, matching: .images) {
                            Text(replaceLabel)
                        }
                    }
                }
            }
        }
        .photosPicker(isPresented: $isPickerPresented, selection: $pickerItem, matching: .images)
        .onAppear {
            content = block.map
            loadImage()
        }
        // Le sélecteur doit attendre la fin de la transition du plein écran,
        // sinon sa présentation est annulée par l'animation en cours.
        .task {
            guard autoPresentPicker, block.map.imageFileName == nil else { return }
            try? await Task.sleep(for: .seconds(Theme.AnimationDuration.medium))
            isPickerPresented = true
        }
        .onChange(of: content) { _, newValue in
            block.map = newValue
        }
        .onChange(of: pickerItem) { _, item in
            guard let item else { return }
            importImage(item)
        }
        .alert(
            localization.string(.mapPinLabelPlaceholder),
            isPresented: Binding(
                get: { editingPin != nil },
                set: { if !$0 { editingPin = nil } }
            )
        ) {
            TextField(localization.string(.mapPinLabelPlaceholder), text: $editingLabel)
            Button(localization.string(.commonDelete), role: .destructive) { deleteEditingPin() }
            Button(localization.string(.commonDone)) { saveEditingLabel() }
        }
    }

    // MARK: Sélecteur d'image

    private var imagePicker: some View {
        let addLabel = localization.string(.mapAddImage)

        return PhotosPicker(selection: $pickerItem, matching: .images) {
            VStack(spacing: Theme.Spacing.medium) {
                Image(systemName: "map")
                    .font(.system(size: Theme.FontSize.largeTitle))
                    .foregroundStyle(theme.accent)
                Text(addLabel)
                    .font(.system(size: Theme.FontSize.body, weight: .semibold))
                    .foregroundStyle(theme.accent)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, Theme.Spacing.xLarge)
            .background(
                RoundedRectangle(cornerRadius: Theme.Radius.medium, style: .continuous)
                    .strokeBorder(theme.accent.opacity(0.4),
                                  style: StrokeStyle(lineWidth: 1, dash: [5]))
            )
        }
    }

    // MARK: Actions

    private func startEditing(_ pin: MapPin) {
        editingPin = pin
        editingLabel = pin.label
    }

    private func saveEditingLabel() {
        guard let id = editingPin?.id,
              let index = content.pins.firstIndex(where: { $0.id == id }) else { return }
        content.pins[index].label = editingLabel
        editingPin = nil
    }

    private func deleteEditingPin() {
        guard let id = editingPin?.id else { return }
        content.pins.removeAll { $0.id == id }
        editingPin = nil
    }

    private func importImage(_ item: PhotosPickerItem) {
        Task {
            guard let data = try? await item.loadTransferable(type: Data.self),
                  let name = ImageStore.save(data) else { return }
            await MainActor.run {
                if let old = content.imageFileName { ImageStore.delete(fileName: old) }
                content.imageFileName = name
                loadImage()
                pickerItem = nil
            }
        }
    }

    private func loadImage() {
        guard let name = content.imageFileName else { image = nil; return }
        image = UIImage(contentsOfFile: ImageStore.url(for: name).path)
    }

    private var background: some View {
        LinearGradient(
            colors: [theme.backgroundDeep, theme.background],
            startPoint: .top, endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}
