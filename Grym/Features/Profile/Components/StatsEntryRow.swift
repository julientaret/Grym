//
//  StatsEntryRow.swift
//  Grym
//
//  Ligne d'accès au bilan personnel depuis le profil. Le bilan est un
//  avantage premium (cf. `PremiumUpgradeView`) : hors droit, la ligne
//  ouvre le prompt d'upgrade au lieu de l'écran.
//

import SwiftUI

struct StatsEntryRow: View {
    var onOpen: () -> Void
    var onLocked: () -> Void

    @EnvironmentObject private var localization: LocalizationManager
    @EnvironmentObject private var premium: PremiumManager
    @Environment(\.theme) private var theme

    var body: some View {
        Button {
            premium.isPremium ? onOpen() : onLocked()
        } label: {
            HStack(spacing: Theme.Spacing.medium) {
                Image(systemName: "chart.bar.fill")
                    .font(.system(size: Theme.FontSize.body, weight: .semibold))
                    .foregroundStyle(theme.accent)

                VStack(alignment: .leading, spacing: 2) {
                    Text(localization.string(.statsTitle))
                        .font(.system(size: Theme.FontSize.body, weight: .semibold))
                        .foregroundStyle(theme.primaryText)
                    Text(localization.string(.statsHint))
                        .font(.system(size: Theme.FontSize.caption))
                        .foregroundStyle(theme.secondaryText)
                        .multilineTextAlignment(.leading)
                }

                Spacer(minLength: Theme.Spacing.small)

                if premium.isPremium {
                    Image(systemName: "chevron.right")
                        .font(.system(size: Theme.FontSize.caption, weight: .bold))
                        .foregroundStyle(theme.secondaryText)
                } else {
                    Text(localization.string(.profileThemePremium))
                        .font(.system(size: Theme.FontSize.caption, weight: .bold))
                        .foregroundStyle(theme.accent)
                        .padding(.horizontal, Theme.Spacing.small)
                        .padding(.vertical, Theme.Spacing.xSmall)
                        .background(Capsule().fill(theme.accent.opacity(0.15)))
                }
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    StatsEntryRow(onOpen: {}, onLocked: {})
        .padding()
        .background(Color.grymBgDark)
        .environmentObject(LocalizationManager())
        .environmentObject(PremiumManager())
        .environment(\.theme, GrymBlueTheme())
}
