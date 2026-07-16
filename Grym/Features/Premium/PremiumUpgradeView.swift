//
//  PremiumUpgradeView.swift
//  Grym
//
//  Prompt d'upgrade premium, présenté quand la limite gratuite (10 jeux)
//  est atteinte. L'achat réel sera branché sur StoreKit ultérieurement.
//

import SwiftUI

struct PremiumUpgradeView: View {
    @EnvironmentObject private var localization: LocalizationManager
    @EnvironmentObject private var premium: PremiumManager
    @Environment(\.theme) private var theme
    @Environment(\.dismiss) private var dismiss

    private var benefits: [(icon: String, key: TranslationKey)] {
        [
            ("infinity", .premiumBenefitUnlimited),
            ("icloud", .premiumBenefitSync),
            ("paintpalette", .premiumBenefitThemes),
            ("square.and.arrow.up", .premiumBenefitExport),
            ("apps.iphone", .premiumBenefitWidgets),
            ("chart.bar", .premiumBenefitStats)
        ]
    }

    var body: some View {
        ZStack {
            background

            VStack(alignment: .leading, spacing: Theme.Spacing.large) {
                header

                VStack(alignment: .leading, spacing: Theme.Spacing.medium) {
                    ForEach(benefits, id: \.key) { benefit in
                        benefitRow(icon: benefit.icon, text: localization.string(benefit.key))
                    }
                }

                Spacer()

                Text(localization.string(.premiumFreeHint))
                    .font(.system(size: Theme.FontSize.caption))
                    .foregroundStyle(theme.secondaryText)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)

                purchaseButton

                Button {
                    Task { await premium.restore(); dismissIfPremium() }
                } label: {
                    Text(localization.string(.premiumRestore))
                        .font(.system(size: Theme.FontSize.caption, weight: .medium))
                        .foregroundStyle(theme.secondaryText)
                        .frame(maxWidth: .infinity)
                }
                .disabled(premium.isPurchasing)

                Button {
                    dismiss()
                } label: {
                    Text(localization.string(.premiumLater))
                        .font(.system(size: Theme.FontSize.body, weight: .medium))
                        .foregroundStyle(theme.secondaryText)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(Theme.Spacing.xLarge)
        }
    }

    private func dismissIfPremium() {
        if premium.isPremium { dismiss() }
    }

    // MARK: En-tête

    private var header: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.small) {
            Image(systemName: "crown.fill")
                .font(.system(size: Theme.FontSize.largeTitle))
                .foregroundStyle(
                    LinearGradient(colors: [theme.accent, theme.accentAlt],
                                   startPoint: .leading, endPoint: .trailing)
                )
            Text(localization.string(.premiumTitle))
                .font(.system(size: Theme.FontSize.largeTitle, weight: .bold))
                .foregroundStyle(theme.primaryText)
            Text(localization.string(.premiumLimitReached))
                .font(.system(size: Theme.FontSize.body))
                .foregroundStyle(theme.secondaryText)
        }
    }

    private func benefitRow(icon: String, text: String) -> some View {
        HStack(spacing: Theme.Spacing.medium) {
            Image(systemName: icon)
                .font(.system(size: Theme.FontSize.body, weight: .semibold))
                .foregroundStyle(theme.accent)
                .frame(width: 28)
            Text(text)
                .font(.system(size: Theme.FontSize.body))
                .foregroundStyle(theme.primaryText)
        }
    }

    private var purchaseButton: some View {
        Button {
            Task {
                if await premium.purchase() { dismiss() }
            }
        } label: {
            Group {
                if premium.isPurchasing {
                    ProgressView().tint(.white)
                } else {
                    Text(purchaseLabel)
                }
            }
            .font(.system(size: Theme.FontSize.body, weight: .bold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, Theme.Spacing.medium)
            .background(
                RoundedRectangle(cornerRadius: Theme.Radius.medium, style: .continuous)
                    .fill(LinearGradient(colors: [theme.accentAlt, theme.brand],
                                         startPoint: .topLeading, endPoint: .bottomTrailing))
            )
        }
        .disabled(premium.isPurchasing || premium.product == nil)
    }

    /// « Débloquer — 4,99 € » avec le prix localisé StoreKit, sinon « Débloquer ».
    private var purchaseLabel: String {
        if let price = premium.displayPrice {
            return "\(localization.string(.premiumUnlock)) — \(price)"
        }
        return localization.string(.premiumUnlock)
    }

    private var background: some View {
        LinearGradient(
            colors: [theme.backgroundDeep, theme.background],
            startPoint: .top, endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}

#Preview {
    PremiumUpgradeView()
        .environmentObject(LocalizationManager())
        .environmentObject(PremiumManager())
        .environment(\.theme, GrymBlueTheme())
}
