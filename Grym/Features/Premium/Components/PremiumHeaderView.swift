//
//  PremiumHeaderView.swift
//  Grym
//
//  En-tête du paywall : badge trophée, nom de l'édition en titre de menu,
//  promesse en une phrase et bandeau expliquant ce qui vient d'être verrouillé.
//

import SwiftUI

struct PremiumHeaderView: View {
    let context: PremiumContext
    let isPremium: Bool

    @EnvironmentObject private var localization: LocalizationManager
    @Environment(\.theme) private var theme

    var body: some View {
        VStack(spacing: Theme.Spacing.medium) {
            PremiumBadgeView(isUnlocked: isPremium)

            VStack(spacing: Theme.Spacing.small) {
                PremiumHUDLabel(text: localization.string(.premiumKicker))

                Text(localization.string(isPremium ? .premiumActiveTitle : .premiumTitle))
                    .font(.system(size: Theme.FontSize.title, weight: .heavy, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(colors: [theme.primaryText, theme.accent],
                                       startPoint: .top, endPoint: .bottom)
                    )

                Text(localization.string(isPremium ? .premiumActiveMessage : .premiumTagline))
                    .font(.system(size: Theme.FontSize.body))
                    .foregroundStyle(theme.secondaryText)
            }
            .multilineTextAlignment(.center)

            if !isPremium, let reasonKey = context.reasonKey {
                reasonBanner(localization.string(reasonKey))
            }
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: Bandeau de contexte

    /// Façon notification de jeu : ce qui vient d'être bloqué, en une ligne.
    private func reasonBanner(_ text: String) -> some View {
        HStack(spacing: Theme.Spacing.small) {
            Image(systemName: context.reasonIcon)
                .font(.system(size: Theme.FontSize.caption, weight: .semibold))
            Text(text)
                .font(.system(size: Theme.FontSize.caption, weight: .medium))
                .multilineTextAlignment(.leading)
        }
        .foregroundStyle(theme.accent)
        .padding(.horizontal, Theme.Spacing.medium)
        .padding(.vertical, Theme.Spacing.small)
        .background(
            Capsule(style: .continuous)
                .fill(theme.accent.opacity(0.12))
                .overlay(Capsule(style: .continuous).stroke(theme.accent.opacity(0.35), lineWidth: 1))
        )
    }
}

#Preview {
    VStack(spacing: Theme.Spacing.xLarge) {
        PremiumHeaderView(context: .gameLimit, isPremium: false)
        PremiumHeaderView(context: .general, isPremium: true)
    }
    .padding()
    .background(Color.grymBgDark)
    .environmentObject(LocalizationManager())
    .environment(\.theme, GrymBlueTheme())
}
