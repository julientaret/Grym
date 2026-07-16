//
//  MediaViewerView.swift
//  Grym
//
//  Visionneuse plein écran des médias IGDB d'un jeu : pagination horizontale
//  sur fond sombre. MVVM non pertinent ici (aucune logique métier, simple
//  présentation d'une liste d'`image_id` fournie par l'appelant).
//

import SwiftUI

/// Médias à ouvrir en plein écran, à partir d'une image donnée.
struct MediaViewerItem: Identifiable, Hashable {
    let imageIds: [String]
    /// Image affichée à l'ouverture.
    let startId: String

    var id: String { startId }
}

struct MediaViewerView: View {
    let item: MediaViewerItem

    @EnvironmentObject private var localization: LocalizationManager
    @Environment(\.dismiss) private var dismiss

    @State private var selection: String

    init(item: MediaViewerItem) {
        self.item = item
        _selection = State(initialValue: item.startId)
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            TabView(selection: $selection) {
                ForEach(item.imageIds, id: \.self) { imageId in
                    AsyncImage(url: IGDBImageSize.fullHD.url(imageId: imageId)) { phase in
                        switch phase {
                        case .success(let image):
                            image.resizable().scaledToFit()
                        case .failure:
                            Image(systemName: "photo")
                                .font(.system(size: Theme.FontSize.largeTitle))
                                .foregroundStyle(.white.opacity(0.4))
                        default:
                            ProgressView().tint(.white)
                        }
                    }
                    .tag(imageId)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))
        }
        .overlay(alignment: .topTrailing) { closeButton }
    }

    private var closeButton: some View {
        Button { dismiss() } label: {
            Image(systemName: "xmark")
                .font(.system(size: Theme.FontSize.body, weight: .semibold))
                .foregroundStyle(.white)
                .padding(Theme.Spacing.small + 2)
                .background(Circle().fill(.black.opacity(0.5)))
        }
        .buttonStyle(.plain)
        .padding(Theme.Spacing.medium)
        .accessibilityLabel(localization.string(.commonDone))
    }
}

#Preview {
    MediaViewerView(
        item: MediaViewerItem(imageIds: ["scagdm", "scagdn", "ar3m1p"], startId: "scagdm")
    )
    .environmentObject(LocalizationManager())
}
