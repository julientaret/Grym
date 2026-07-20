//
//  BannerHeaderView.swift
//  Grym
//
//  Bannière illustrée d'en-tête d'onglet : image de fond assombrie,
//  fondue en alpha vers le bas, avec un contenu libre superposé.
//

import SwiftUI

struct BannerHeaderView<Content: View>: View {
    /// Nom de l'image dans le catalogue d'assets.
    let imageName: String
    @ViewBuilder let content: () -> Content

    @Environment(\.theme) private var theme

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            banner
            overlayContent
        }
        .frame(height: Theme.Size.bannerHeight)
        .frame(maxWidth: .infinity)
    }

    // MARK: Image et overlay

    /// `Color.clear` impose la taille du conteneur ; l'image en `overlay`
    /// déborde puis est rognée, sans jamais élargir la vue parente.
    private var banner: some View {
        Color.clear
            .overlay {
                Image(imageName)
                    .resizable()
                    .scaledToFill()
            }
            .clipped()
            .overlay(overlayGradient)
            .mask(fadeMask)
    }

    /// Assombrit progressivement l'image pour garantir la lisibilité du texte.
    private var overlayGradient: some View {
        LinearGradient(
            stops: [
                .init(color: theme.backgroundDeep.opacity(0.15), location: 0),
                .init(color: theme.backgroundDeep.opacity(0.55), location: 0.55),
                .init(color: theme.backgroundDeep.opacity(0.85), location: 1)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    /// Fait disparaître le bas de la bannière en alpha : le fond réel de
    /// l'écran (dégradé + halo) transparaît, sans raccord visible.
    private var fadeMask: some View {
        LinearGradient(
            stops: [
                .init(color: .black, location: 0),
                .init(color: .black, location: 0.6),
                .init(color: .black.opacity(0.35), location: 0.85),
                .init(color: .clear, location: 1)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    // MARK: Contenu superposé

    private var overlayContent: some View {
        content()
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, Theme.Spacing.large)
            .padding(.bottom, Theme.Spacing.medium)
    }
}

#Preview {
    BannerHeaderView(imageName: "banner-home") {
        Text("Grym")
            .font(.system(size: Theme.FontSize.largeTitle, weight: .bold))
            .foregroundStyle(.white)
    }
    .background(Color.grymBgDark)
    .environment(\.theme, GrymBlueTheme())
}
