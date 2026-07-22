//
//  PremiumBenefitRow.swift
//  Grym
//
//  Ligne d'avantage du paywall : icône accentuée, intitulé et explication
//  courte de ce que l'achat change concrètement.
//

import SwiftUI

struct PremiumBenefitRow: View {
    let benefit: PremiumBenefit

    @EnvironmentObject private var localization: LocalizationManager
    @Environment(\.theme) private var theme

    var body: some View {
        HStack(alignment: .top, spacing: Theme.Spacing.medium) {
            Image(systemName: benefit.icon)
                .font(.system(size: Theme.FontSize.body, weight: .semibold))
                .foregroundStyle(theme.accent)
                .frame(width: Theme.Size.premiumBenefitIcon,
                       height: Theme.Size.premiumBenefitIcon)
                .background(
                    RoundedRectangle(cornerRadius: Theme.Radius.medium, style: .continuous)
                        .fill(theme.accent.opacity(0.14))
                )

            VStack(alignment: .leading, spacing: Theme.Spacing.xSmall) {
                Text(localization.string(benefit.titleKey))
                    .font(.system(size: Theme.FontSize.body, weight: .semibold))
                    .foregroundStyle(theme.primaryText)
                Text(localization.string(benefit.detailKey))
                    .font(.system(size: Theme.FontSize.caption))
                    .foregroundStyle(theme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
    }
}

#Preview {
    VStack(spacing: Theme.Spacing.large) {
        ForEach(PremiumBenefit.all) { PremiumBenefitRow(benefit: $0) }
    }
    .padding()
    .background(Color.grymBgDark)
    .environmentObject(LocalizationManager())
    .environment(\.theme, GrymBlueTheme())
}
