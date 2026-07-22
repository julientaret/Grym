//
//  PremiumHeaderView.swift
//  Grym
//
//  En-tête du paywall : pastille couronne halo, titre, promesse en une phrase
//  et bandeau expliquant ce qui vient d'être verrouillé (selon le contexte).
//

import SwiftUI

struct PremiumHeaderView: View {
    let context: PremiumContext
    let isPremium: Bool

    @EnvironmentObject private var localization: LocalizationManager
    @Environment(\.theme) private var theme

    var body: some View {
        VStack(spacing: Theme.Spacing.medium) {
            crest

            VStack(spacing: Theme.Spacing.small) {
                Text(localization.string(isPremium ? .premiumActiveTitle : .premiumTitle))
                    .font(.system(size: Theme.FontSize.title, weight: .bold))
                    .foregroundStyle(theme.primaryText)

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

    // MARK: Pastille

    private var crest: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(colors: [theme.glow.opacity(0.9), .clear],
                                   center: .center, startRadius: 0,
                                   endRadius: Theme.Size.premiumCrest)
                )
                .frame(width: Theme.Size.premiumCrest * 2,
                       height: Theme.Size.premiumCrest * 2)

            Circle()
                .fill(
                    LinearGradient(colors: [theme.accent, theme.accentAlt],
                                   startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .frame(width: Theme.Size.premiumCrest, height: Theme.Size.premiumCrest)
                .overlay(
                    Image(systemName: isPremium ? "checkmark" : "crown.fill")
                        .font(.system(size: Theme.FontSize.title, weight: .bold))
                        .foregroundStyle(.white)
                )
        }
    }

    // MARK: Bandeau de contexte

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
