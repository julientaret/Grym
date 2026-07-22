//
//  PremiumPurchaseFooter.swift
//  Grym
//
//  Pied du paywall, épinglé bas d'écran : bouton d'achat avec prix localisé,
//  mention « achat unique » et restauration.
//

import SwiftUI

struct PremiumPurchaseFooter: View {
    @EnvironmentObject private var localization: LocalizationManager
    @EnvironmentObject private var premium: PremiumManager
    @Environment(\.theme) private var theme

    /// Appelé quand le droit premium vient d'être obtenu (achat ou restauration).
    let onUnlocked: () -> Void

    var body: some View {
        VStack(spacing: Theme.Spacing.small) {
            purchaseButton

            Text(localization.string(.premiumOneTimeNote))
                .font(.system(size: Theme.FontSize.caption))
                .foregroundStyle(theme.secondaryText)
                .multilineTextAlignment(.center)

            Button {
                Task {
                    await premium.restore()
                    if premium.isPremium { onUnlocked() }
                }
            } label: {
                Text(localization.string(.premiumRestore))
                    .font(.system(size: Theme.FontSize.caption, weight: .medium))
                    .foregroundStyle(theme.secondaryText)
                    .frame(maxWidth: .infinity)
            }
            .disabled(premium.isPurchasing)
        }
    }

    private var purchaseButton: some View {
        Button {
            Task {
                if await premium.purchase() { onUnlocked() }
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
                RoundedRectangle(cornerRadius: Theme.Radius.large, style: .continuous)
                    .fill(LinearGradient(colors: [theme.accent, theme.accentAlt],
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
}

#Preview {
    PremiumPurchaseFooter(onUnlocked: {})
        .padding()
        .background(Color.grymBgDark)
        .environmentObject(LocalizationManager())
        .environmentObject(PremiumManager())
        .environment(\.theme, GrymBlueTheme())
}
