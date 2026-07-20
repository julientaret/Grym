//
//  MapBlockView.swift
//  Grym
//
//  Bloc carte annotée dans l'éditeur de page : aperçu (image + pins)
//  ou invite d'ajout ; ouvre l'éditeur plein écran au tap.
//

import SwiftUI
import UIKit

struct MapBlockView: View {
    @Bindable var block: Block
    /// Bloc tout juste créé : l'éditeur s'ouvre et propose l'image directement.
    var autoPresentPicker: Bool = false
    var onPickerPresented: () -> Void = {}

    @EnvironmentObject private var localization: LocalizationManager
    @Environment(\.theme) private var theme

    @State private var content = MapContent()
    @State private var image: UIImage?
    @State private var showingEditor = false
    @State private var showingFullScreen = false
    /// Transmis à l'éditeur pour qu'il ouvre son sélecteur d'images.
    @State private var editorAutoPresentsPicker = false

    var body: some View {
        preview
        .onAppear {
            content = block.map
            loadImage()
            guard autoPresentPicker else { return }
            onPickerPresented()
            editorAutoPresentsPicker = true
            showingEditor = true
        }
        .fullScreenCover(isPresented: $showingEditor, onDismiss: {
            editorAutoPresentsPicker = false
            content = block.map
            loadImage()
        }) {
            MapEditorView(block: block, autoPresentPicker: editorAutoPresentsPicker)
        }
        .fullScreenCover(isPresented: $showingFullScreen) {
            if let image {
                MapFullScreenView(image: image, pins: content.pins)
            }
        }
    }

    /// L'aperçu porte deux actions distinctes (éditer / plein écran) : les
    /// pastilles doivent donc être de vrais boutons, hors d'un bouton parent.
    @ViewBuilder
    private var preview: some View {
        if let image {
            AnnotatedMapView(image: image, pins: .constant(content.pins))
                .contentShape(Rectangle())
                .onTapGesture { showingEditor = true }
                .overlay(alignment: .bottomTrailing) { chips(for: image) }
        } else {
            Button { showingEditor = true } label: { placeholder }
                .buttonStyle(.plain)
        }
    }

    private func chips(for image: UIImage) -> some View {
        HStack(spacing: Theme.Spacing.small) {
            chip(systemImage: "arrow.up.left.and.arrow.down.right",
                 label: localization.string(.mapFullScreen)) {
                showingFullScreen = true
            }
            chip(systemImage: "pencil",
                 label: localization.string(.blockTypeMap)) {
                showingEditor = true
            }
        }
        .padding(Theme.Spacing.small)
    }

    private func chip(systemImage: String,
                      label: String,
                      action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: Theme.FontSize.caption, weight: .bold))
                .foregroundStyle(.white)
                .padding(Theme.Spacing.small)
                .background(Circle().fill(.black.opacity(0.5)))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
    }

    private var placeholder: some View {
        VStack(spacing: Theme.Spacing.small) {
            Image(systemName: "map")
                .font(.system(size: Theme.FontSize.title))
                .foregroundStyle(theme.accent)
            Text(localization.string(.mapAddImage))
                .font(.system(size: Theme.FontSize.caption, weight: .semibold))
                .foregroundStyle(theme.accent)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Theme.Spacing.xLarge)
        .background(
            RoundedRectangle(cornerRadius: Theme.Radius.medium, style: .continuous)
                .fill(theme.surface.opacity(0.4))
        )
    }

    private func loadImage() {
        guard let name = content.imageFileName else { image = nil; return }
        image = UIImage(contentsOfFile: ImageStore.url(for: name).path)
    }
}
