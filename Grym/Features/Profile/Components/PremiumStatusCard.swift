//
//  PremiumStatusCard.swift
//  Grym
//
//  Accès au paywall depuis le Profil : rappelle l'état du droit premium
//  (actif ou palier gratuit) et ouvre `PremiumUpgradeView`.
//

import SwiftUI

struct PremiumStatusCard: View {
    @EnvironmentObject private var localization: LocalizationManager
    @EnvironmentObject private var premium: PremiumManager
    @Environment(\.theme) private var theme

    @State private var showingUpgrade = false

    var body: some View {
        Button {
            showingUpgrade = true
        } label: {
            HStack(spacing: Theme.Spacing.medium) {
                icon

                VStack(alignment: .leading, spacing: Theme.Spacing.xSmall) {
                    Text(localization.string(premium.isPremium ? .premiumActiveTitle : .profilePremiumCTA))
                        .font(.system(size: Theme.FontSize.body, weight: .semibold))
                        .foregroundStyle(theme.primaryText)
                    Text(localization.string(premium.isPremium ? .premiumActiveMessage : .premiumTagline))
                        .font(.system(size: Theme.FontSize.caption))
                        .foregroundStyle(theme.secondaryText)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 0)

                Image(systemName: "chevron.right")
                    .font(.system(size: Theme.FontSize.caption, weight: .semibold))
                    .foregroundStyle(theme.secondaryText)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showingUpgrade) {
            PremiumUpgradeView()
        }
    }

    private var icon: some View {
        Image(systemName: premium.isPremium ? "checkmark.seal.fill" : "crown.fill")
            .font(.system(size: Theme.FontSize.body, weight: .semibold))
            .foregroundStyle(.white)
            .frame(width: Theme.Size.premiumBenefitIcon, height: Theme.Size.premiumBenefitIcon)
            .background(
                RoundedRectangle(cornerRadius: Theme.Radius.medium, style: .continuous)
                    .fill(LinearGradient(colors: [theme.accent, theme.accentAlt],
                                         startPoint: .topLeading, endPoint: .bottomTrailing))
            )
    }
}

#Preview {
    PremiumStatusCard()
        .padding()
        .background(Color.grymBgDark)
        .environmentObject(LocalizationManager())
        .environmentObject(PremiumManager())
        .environment(\.theme, GrymBlueTheme())
}
