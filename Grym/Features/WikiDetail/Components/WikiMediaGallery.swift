//
//  WikiMediaGallery.swift
//  Grym
//
//  Galerie horizontale des médias IGDB d'un jeu (captures + illustrations).
//  Vignettes en lazy loading depuis le CDN ; l'appui ouvre la visionneuse.
//

import SwiftUI

struct WikiMediaGallery: View {
    let imageIds: [String]
    let tint: Color
    let onOpen: (String) -> Void

    @EnvironmentObject private var localization: LocalizationManager
    @Environment(\.theme) private var theme

    private let thumbnailWidth: CGFloat = 208
    private let thumbnailHeight: CGFloat = 117   // 16:9

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.small) {
            header
                .padding(.horizontal, Theme.Spacing.large)

            ScrollView(.horizontal) {
                LazyHStack(spacing: Theme.Spacing.small + 2) {
                    ForEach(imageIds, id: \.self) { imageId in
                        Button { onOpen(imageId) } label: {
                            thumbnail(imageId)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.viewAligned)
            .scrollIndicators(.hidden)
            // Marges de contenu plutôt qu'un padding : les vignettes défilent
            // ainsi jusqu'aux bords de l'écran, alignées sur les autres cartes.
            .contentMargins(.horizontal, Theme.Spacing.large, for: .scrollContent)
        }
    }

    // MARK: En-tête

    private var header: some View {
        HStack(spacing: Theme.Spacing.xSmall + 2) {
            Text(localization.string(.wikiMediaTitle))
                .font(.system(size: Theme.FontSize.body, weight: .semibold))
                .foregroundStyle(theme.primaryText)
            Text("· \(imageIds.count)")
                .font(.system(size: Theme.FontSize.body, weight: .semibold))
                .foregroundStyle(theme.secondaryText)
        }
    }

    // MARK: Vignette

    private func thumbnail(_ imageId: String) -> some View {
        AsyncImage(url: IGDBImageSize.screenshotMed.url(imageId: imageId)) { phase in
            switch phase {
            case .success(let image):
                image.resizable().scaledToFill()
            default:
                LinearGradient(
                    colors: [tint.opacity(0.3), .black.opacity(0.35)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        }
        .frame(width: thumbnailWidth, height: thumbnailHeight)
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.medium, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.Radius.medium, style: .continuous)
                .strokeBorder(.white.opacity(0.08), lineWidth: 1)
        )
    }
}

#Preview {
    WikiMediaGallery(
        imageIds: ["scagdm", "scagdn", "scagdo", "ar3m1p"],
        tint: Color(hex: 0xE0A458),
        onOpen: { _ in }
    )
    .padding(.vertical)
    .background(Color.grymBgDark)
    .environmentObject(LocalizationManager())
    .environment(\.theme, GrymBlueTheme())
}
