//
//  AddGameButton.swift
//  Grym
//
//  Boutons d'ajout de jeu : variante circulaire (en-tête) et
//  variante pleine largeur (bas de liste).
//

import SwiftUI

/// Bouton circulaire « + » (coin de l'en-tête).
struct CircularAddGameButton: View {
    let action: () -> Void
    @EnvironmentObject private var localization: LocalizationManager
    @Environment(\.theme) private var theme

    var body: some View {
        Button(action: action) {
            Image(systemName: "plus")
                .font(.system(size: Theme.FontSize.body, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 44, height: 44)
                .background(Circle().fill(addGradient(theme)))
        }
        .accessibilityLabel(localization.string(.gameSearchTitle))
    }
}

/// Bouton pleine largeur « Ajouter un jeu » (bas de liste).
struct WideAddGameButton: View {
    let action: () -> Void
    @EnvironmentObject private var localization: LocalizationManager
    @Environment(\.theme) private var theme

    var body: some View {
        Button(action: action) {
            HStack(spacing: Theme.Spacing.small) {
                Image(systemName: "plus")
                Text(localization.string(.gameSearchTitle))
            }
            .font(.system(size: Theme.FontSize.body, weight: .semibold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, Theme.Spacing.medium)
            .background(
                RoundedRectangle(cornerRadius: Theme.Radius.medium, style: .continuous)
                    .fill(addGradient(theme))
            )
        }
    }
}

/// Bouton capsule « Ajouter un jeu » (superposé à la bannière d'accueil).
struct CompactAddGameButton: View {
    let action: () -> Void
    @EnvironmentObject private var localization: LocalizationManager
    @Environment(\.theme) private var theme

    var body: some View {
        Button(action: action) {
            HStack(spacing: Theme.Spacing.small) {
                Image(systemName: "plus")
                Text(localization.string(.gameSearchTitle))
            }
            .font(.system(size: Theme.FontSize.body, weight: .semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, Theme.Spacing.medium)
            .padding(.vertical, Theme.Spacing.small)
            .background(Capsule().fill(addGradient(theme)))
        }
    }
}

private func addGradient(_ theme: any AppTheme) -> LinearGradient {
    LinearGradient(
        colors: [theme.accentAlt, theme.brand],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

#Preview {
    VStack(spacing: Theme.Spacing.large) {
        CircularAddGameButton(action: {})
        CompactAddGameButton(action: {})
        WideAddGameButton(action: {})
    }
    .padding()
    .background(Color.grymBgDark)
    .environmentObject(LocalizationManager())
    .environment(\.theme, GrymBlueTheme())
}
