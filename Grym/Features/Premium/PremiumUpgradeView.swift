//
//  PremiumUpgradeView.swift
//  Grym
//
//  Paywall : ce que l'achat unique débloque, expliqué avantage par avantage.
//  Ouvert volontairement depuis le Profil, ou quand une limite est atteinte
//  (ajout de jeu, thème verrouillé, bilan complet).
//

import SwiftUI

struct PremiumUpgradeView: View {
    /// Ce qui a déclenché l'ouverture ; sert à expliquer le blocage.
    var context: PremiumContext = .general

    @EnvironmentObject private var localization: LocalizationManager
    @EnvironmentObject private var premium: PremiumManager
    @Environment(\.theme) private var theme
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack(alignment: .topTrailing) {
            background

            VStack(spacing: Theme.Spacing.large) {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: Theme.Spacing.xLarge) {
                        PremiumHeaderView(context: context, isPremium: premium.isPremium)
                        benefitsCard
                        if context == .gameLimit && !premium.isPremium {
                            freeHint
                        }
                    }
                    .padding(.top, Theme.Spacing.xLarge)
                    .padding(.bottom, Theme.Spacing.medium)
                }

                if premium.isPremium {
                    closeButton
                } else {
                    PremiumPurchaseFooter { dismiss() }
                }
            }
            .padding(.horizontal, Theme.Spacing.large)
            .padding(.bottom, Theme.Spacing.medium)

            dismissButton
        }
    }

    // MARK: Avantages

    private var benefitsCard: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.large) {
            ForEach(PremiumBenefit.all) { PremiumBenefitRow(benefit: $0) }
        }
        .padding(Theme.Spacing.medium)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: Theme.Radius.large, style: .continuous)
                .fill(theme.surface.opacity(0.5))
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.Radius.large, style: .continuous)
                        .stroke(.white.opacity(0.06), lineWidth: 1)
                )
        )
    }

    /// Rappelé seulement quand la limite gratuite bloque : il reste une issue sans payer.
    private var freeHint: some View {
        Text(localization.string(.premiumFreeHint))
            .font(.system(size: Theme.FontSize.caption))
            .foregroundStyle(theme.secondaryText)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
    }

    // MARK: Fermeture

    private var closeButton: some View {
        Button {
            dismiss()
        } label: {
            Text(localization.string(.commonClose))
                .font(.system(size: Theme.FontSize.body, weight: .bold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Theme.Spacing.medium)
                .background(
                    RoundedRectangle(cornerRadius: Theme.Radius.large, style: .continuous)
                        .fill(LinearGradient(colors: [theme.accent, theme.accentAlt],
                                             startPoint: .topLeading, endPoint: .bottomTrailing))
                )
        }
    }

    private var dismissButton: some View {
        Button {
            dismiss()
        } label: {
            Image(systemName: "xmark")
                .font(.system(size: Theme.FontSize.caption, weight: .bold))
                .foregroundStyle(theme.secondaryText)
                .padding(Theme.Spacing.small)
                .background(Circle().fill(theme.surface.opacity(0.6)))
        }
        .padding(Theme.Spacing.medium)
        .accessibilityLabel(localization.string(.commonClose))
    }

    // MARK: Fond

    private var background: some View {
        ZStack {
            LinearGradient(
                colors: [theme.backgroundDeep, theme.background],
                startPoint: .top, endPoint: .bottom
            )
            RadialGradient(
                colors: [theme.glow.opacity(0.5), .clear],
                center: UnitPoint(x: 0.5, y: 0.05),
                startRadius: 4,
                endRadius: 360
            )
        }
        .ignoresSafeArea()
    }
}

#Preview("Limite atteinte") {
    PremiumUpgradeView(context: .gameLimit)
        .environmentObject(LocalizationManager())
        .environmentObject(PremiumManager())
        .environment(\.theme, GrymBlueTheme())
}

#Preview("Depuis le profil") {
    PremiumUpgradeView()
        .environmentObject(LocalizationManager())
        .environmentObject(PremiumManager())
        .environment(\.theme, GrymBlueTheme())
}
