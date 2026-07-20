//
//  HomeHeaderView.swift
//  Grym
//
//  En-tête de l'accueil : bannière illustrée avec titre « Grym »,
//  tagline et bouton d'ajout de jeu superposés.
//

import SwiftUI

struct HomeHeaderView: View {
    /// Déclenche l'ouverture de la recherche de jeu.
    let onAddGame: () -> Void

    @EnvironmentObject private var localization: LocalizationManager
    @Environment(\.theme) private var theme

    var body: some View {
        BannerHeaderView(imageName: "banner-home") {
            VStack(alignment: .leading, spacing: Theme.Spacing.xSmall) {
                Text("Grym")
                    .font(.system(size: Theme.FontSize.largeTitle, weight: .bold))
                    .foregroundStyle(theme.primaryText)
                Text(localization.string(.appTagline))
                    .font(.system(size: Theme.FontSize.caption, weight: .medium))
                    .foregroundStyle(theme.secondaryText)

                CompactAddGameButton(action: onAddGame)
                    .padding(.top, Theme.Spacing.small)
            }
        }
    }
}

#Preview {
    HomeHeaderView(onAddGame: {})
        .background(Color.grymBgDark)
        .environmentObject(LocalizationManager())
        .environment(\.theme, GrymBlueTheme())
}
