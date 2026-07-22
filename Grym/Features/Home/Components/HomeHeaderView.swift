//
//  HomeHeaderView.swift
//  Grym
//
//  En-tête de l'accueil : bannière illustrée avec titre « Grym »,
//  tagline, bouton d'ajout de jeu et accès à la recherche globale.
//

import SwiftUI

struct HomeHeaderView: View {
    /// Déclenche l'ouverture de la recherche de jeu.
    let onAddGame: () -> Void
    /// Déclenche l'ouverture de la recherche globale dans la collection.
    let onSearch: () -> Void

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

                HStack(spacing: Theme.Spacing.small) {
                    CompactAddGameButton(action: onAddGame)
                    searchButton
                }
                .padding(.top, Theme.Spacing.small)
            }
        }
    }

    private var searchButton: some View {
        Button(action: onSearch) {
            HStack(spacing: Theme.Spacing.xSmall) {
                Image(systemName: "magnifyingglass")
                Text(localization.string(.searchTitle))
            }
            .font(.system(size: Theme.FontSize.caption, weight: .semibold))
            .foregroundStyle(theme.primaryText)
            .padding(.horizontal, Theme.Spacing.medium)
            .padding(.vertical, Theme.Spacing.small)
            .background(Capsule().fill(theme.surface.opacity(0.8)))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    HomeHeaderView(onAddGame: {}, onSearch: {})
        .background(Color.grymBgDark)
        .environmentObject(LocalizationManager())
        .environment(\.theme, GrymBlueTheme())
}
