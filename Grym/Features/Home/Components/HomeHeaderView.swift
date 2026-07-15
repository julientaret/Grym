//
//  HomeHeaderView.swift
//  Grym
//
//  En-tête de l'accueil : titre « Grym », tagline et bouton d'ajout de jeu.
//

import SwiftUI

struct HomeHeaderView: View {
    let onAdd: () -> Void

    @EnvironmentObject private var localization: LocalizationManager
    @Environment(\.theme) private var theme

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: Theme.Spacing.xSmall) {
                Text("Grym")
                    .font(.system(size: Theme.FontSize.largeTitle, weight: .bold))
                    .foregroundStyle(theme.primaryText)
                Text(localization.string(.appTagline))
                    .font(.system(size: Theme.FontSize.caption, weight: .medium))
                    .foregroundStyle(theme.secondaryText)
            }

            Spacer()

            Button(action: onAdd) {
                Image(systemName: "plus")
                    .font(.system(size: Theme.FontSize.body, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle().fill(
                            LinearGradient(
                                colors: [theme.accentAlt, theme.brand],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    )
            }
            .accessibilityLabel("Ajouter un jeu")
        }
    }
}

#Preview {
    HomeHeaderView(onAdd: {})
        .padding()
        .background(Color.grymBgDark)
        .environmentObject(LocalizationManager())
        .environment(\.theme, GrymBlueTheme())
}
