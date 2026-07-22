//
//  PremiumPurchaseFooter.swift
//  Grym
//
//  Pied du paywall, épinglé bas d'écran : bouton d'achat balayé d'un reflet
//  (façon bouton de menu de jeu), mention « achat unique » et restauration.
//

import SwiftUI

struct PremiumPurchaseFooter: View {
    @EnvironmentObject private var localization: LocalizationManager
    @EnvironmentObject private var premium: PremiumManager
    @Environment(\.theme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// Appelé quand le droit premium vient d'être obtenu (achat ou restauration).
    let onUnlocked: () -> Void

    @State private var shineOffset: CGFloat = -1

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
            HStack(spacing: Theme.Spacing.small) {
                if premium.isPurchasing {
                    ProgressView().tint(.white)
                } else {
                    Image(systemName: "lock.open.fill")
                        .font(.system(size: Theme.FontSize.caption, weight: .bold))
                    Text(purchaseLabel)
                }
            }
            .font(.system(size: Theme.FontSize.body, weight: .bold, design: .rounded))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, Theme.Spacing.medium)
            .background(buttonBackground)
            .shadow(color: theme.accent.opacity(0.45), radius: 14, y: 8)
        }
        .disabled(premium.isPurchasing || premium.product == nil)
        .onAppear(perform: startShine)
    }

    private var buttonBackground: some View {
        RoundedRectangle(cornerRadius: Theme.Radius.large, style: .continuous)
            .fill(LinearGradient(colors: [theme.accent, theme.accentAlt],
                                 startPoint: .topLeading, endPoint: .bottomTrailing))
            .overlay(shine)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Radius.large, style: .continuous)
                    .stroke(.white.opacity(0.25), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.large, style: .continuous))
    }

    /// Reflet qui traverse le bouton en boucle lente.
    private var shine: some View {
        GeometryReader { proxy in
            LinearGradient(colors: [.clear, .white.opacity(0.35), .clear],
                           startPoint: .leading, endPoint: .trailing)
                .frame(width: proxy.size.width * 0.4)
                .offset(x: shineOffset * proxy.size.width * 1.4)
                .blendMode(.plusLighter)
        }
        .allowsHitTesting(false)
    }

    private func startShine() {
        guard !reduceMotion else { return }
        withAnimation(.linear(duration: 2.4).repeatForever(autoreverses: false).delay(0.6)) {
            shineOffset = 1
        }
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
