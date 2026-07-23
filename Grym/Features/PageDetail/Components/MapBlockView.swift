//
//  MapBlockView.swift
//  Grym
//
//  Bloc carte annotée dans l'éditeur de page : aperçu (image + pins)
//  ou invite d'ajout. Le tap sur l'image l'ouvre en plein écran ;
//  l'édition passe par le crayon du bandeau.
//

import SwiftUI
import UIKit

struct MapBlockView: View {
    @Bindable var block: Block
    /// Bloc tout juste créé : son nom prend le focus à l'apparition.
    var autofocusTitle: Bool = false
    var onTitleFocused: () -> Void = {}
    var actions: BlockActions?

    @EnvironmentObject private var localization: LocalizationManager
    @Environment(\.theme) private var theme

    @State private var content = MapContent()
    @State private var image: UIImage?
    @State private var showingEditor = false
    @State private var showingFullScreen = false

    private var accent: Color { BlockType.map.accent(in: theme) }

    var body: some View {
        BlockCardView(
            type: .map,
            title: $block.title,
            autofocusTitle: autofocusTitle,
            onTitleFocused: onTitleFocused,
            onTitleSubmitted: presentEditorIfEmpty,
            contentPadding: image == nil ? Theme.Spacing.medium : 0,
            actions: actions,
            accessory: { headerActions },
            content: { preview }
        )
        .onAppear {
            content = block.map
            loadImage()
        }
        .fullScreenCover(isPresented: $showingEditor, onDismiss: {
            content = block.map
            loadImage()
        }) {
            // Sans image, l'éditeur propose directement le sélecteur :
            // c'est la seule action possible à ce stade.
            MapEditorView(block: block, autoPresentPicker: content.imageFileName == nil)
        }
        .fullScreenCover(isPresented: $showingFullScreen) {
            if let image {
                MapFullScreenView(image: image, pins: content.pins)
            }
        }
    }

    /// Enchaîne sur l'éditeur une fois le bloc nommé, tant qu'il n'a pas
    /// d'image : l'éditeur ouvre alors son sélecteur de lui-même.
    private func presentEditorIfEmpty() {
        guard content.imageFileName == nil else { return }
        showingEditor = true
    }

    // MARK: Actions du bandeau

    @ViewBuilder
    private var headerActions: some View {
        if image != nil {
            if !content.pins.isEmpty {
                Label("\(content.pins.count)", systemImage: "mappin")
                    .font(.system(size: Theme.FontSize.caption, weight: .bold))
                    .foregroundStyle(theme.secondaryText)
            }

            BlockHeaderButton(
                systemImage: "pencil",
                label: localization.string(.commonEdit)
            ) {
                showingEditor = true
            }
        }
    }

    // MARK: Aperçu

    @ViewBuilder
    private var preview: some View {
        if let image {
            AnnotatedMapView(image: image, pins: .constant(content.pins))
                .contentShape(Rectangle())
                .onTapGesture { showingFullScreen = true }
                .accessibilityLabel(localization.string(.mapFullScreen))
        } else {
            Button { showingEditor = true } label: { placeholder }
                .buttonStyle(.plain)
        }
    }

    private var placeholder: some View {
        VStack(spacing: Theme.Spacing.small) {
            Image(systemName: "map")
                .font(.system(size: Theme.FontSize.title))
            Text(localization.string(.mapAddImage))
                .font(.system(size: Theme.FontSize.caption, weight: .semibold))
        }
        .foregroundStyle(accent)
        .frame(maxWidth: .infinity)
        .padding(.vertical, Theme.Spacing.large)
        .background(
            RoundedRectangle(cornerRadius: Theme.Radius.medium, style: .continuous)
                .strokeBorder(accent.opacity(0.35), style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
        )
    }

    private func loadImage() {
        guard let name = content.imageFileName else { image = nil; return }
        image = UIImage(contentsOfFile: ImageStore.url(for: name).path)
    }
}

#Preview {
    MapBlockView(block: Block(type: .map, content: "", order: 0))
        .padding()
        .background(Color.grymBgDark)
        .environmentObject(LocalizationManager())
        .environment(\.theme, GrymBlueTheme())
}
