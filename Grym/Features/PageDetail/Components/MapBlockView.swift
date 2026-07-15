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

    @EnvironmentObject private var localization: LocalizationManager
    @Environment(\.theme) private var theme

    @State private var content = MapContent()
    @State private var image: UIImage?
    @State private var showingEditor = false

    var body: some View {
        Button {
            showingEditor = true
        } label: {
            if let image {
                AnnotatedMapView(image: image, pins: .constant(content.pins))
                    .overlay(alignment: .bottomTrailing) { editChip }
            } else {
                placeholder
            }
        }
        .buttonStyle(.plain)
        .onAppear {
            content = block.map
            loadImage()
        }
        .fullScreenCover(isPresented: $showingEditor, onDismiss: {
            content = block.map
            loadImage()
        }) {
            MapEditorView(block: block)
        }
    }

    private var editChip: some View {
        Image(systemName: "pencil")
            .font(.system(size: Theme.FontSize.caption, weight: .bold))
            .foregroundStyle(.white)
            .padding(Theme.Spacing.small)
            .background(Circle().fill(.black.opacity(0.5)))
            .padding(Theme.Spacing.small)
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
