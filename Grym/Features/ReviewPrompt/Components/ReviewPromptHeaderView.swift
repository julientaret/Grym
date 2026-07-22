//
//  ReviewPromptHeaderView.swift
//  Grym
//
//  En-tête de la demande de note : pastille façon succès débloqué,
//  libellé HUD, titre de menu et promesse en une phrase.
//

import SwiftUI

struct ReviewPromptHeaderView: View {
    @EnvironmentObject private var localization: LocalizationManager
    @Environment(\.theme) private var theme
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(spacing: Theme.Spacing.medium) {
            crest

            VStack(spacing: Theme.Spacing.small) {
                PremiumHUDLabel(text: localization.string(.reviewPromptKicker))

                Text(localization.string(.reviewPromptTitle))
                    .font(.system(size: Theme.FontSize.title, weight: .heavy, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(colors: [theme.primaryText, theme.accent],
                                       startPoint: .top, endPoint: .bottom)
                    )

                Text(localization.string(.reviewPromptMessage))
                    .font(.system(size: Theme.FontSize.body))
                    .foregroundStyle(theme.secondaryText)
            }
            .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }

    /// Médaille de succès : halo (aura d'accent en thème clair) + pastille.
    private var crest: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: colorScheme == .light
                            ? [theme.accent.opacity(0.22), .clear]
                            : [theme.glow.opacity(0.9), .clear],
                        center: .center, startRadius: 0, endRadius: Theme.Size.reviewCrest
                    )
                )
                .frame(width: Theme.Size.reviewCrest * 2, height: Theme.Size.reviewCrest * 2)

            Circle()
                .fill(
                    LinearGradient(colors: [theme.accent, theme.accentAlt],
                                   startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .frame(width: Theme.Size.reviewCrest, height: Theme.Size.reviewCrest)
                .overlay(
                    Image(systemName: "rosette")
                        .font(.system(size: Theme.FontSize.title, weight: .bold))
                        .foregroundStyle(.white)
                )
                .shadow(color: theme.accent.opacity(0.5), radius: 16, y: 6)
        }
    }
}

#Preview {
    ReviewPromptHeaderView()
        .padding()
        .background(Color.grymBgDark)
        .environmentObject(LocalizationManager())
        .environment(\.theme, GrymBlueTheme())
}
