//
//  WikiMediaGallery.swift
//  Grym
//
//  Galerie horizontale des photos ajoutées par l'utilisateur dans les blocs
//  photo du wiki. Vignettes locales (`ImageStore`) ; l'appui ouvre l'aperçu.
//

import SwiftUI

struct WikiMediaGallery: View {
    /// Fichiers locaux des photos (cf. `ImageStore`).
    let fileNames: [String]
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
                    ForEach(fileNames, id: \.self) { fileName in
                        Button { onOpen(fileName) } label: {
                            thumbnail(fileName)
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
            Text("· \(fileNames.count)")
                .font(.system(size: Theme.FontSize.body, weight: .semibold))
                .foregroundStyle(theme.secondaryText)
        }
    }

    // MARK: Vignette

    private func thumbnail(_ fileName: String) -> some View {
        AsyncImage(url: ImageStore.url(for: fileName)) { phase in
            switch phase {
            case .success(let image):
                image.resizable().scaledToFill()
            default:
                Rectangle().fill(theme.surface.opacity(0.6))
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
    WikiMediaGallery(fileNames: [], onOpen: { _ in })
        .padding(.vertical)
        .background(Color.grymBgDark)
        .environmentObject(LocalizationManager())
        .environment(\.theme, GrymBlueTheme())
}
