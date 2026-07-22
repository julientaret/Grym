//
//  PremiumBenefitRow.swift
//  Grym
//
//  Ligne d'avantage façon succès à débloquer : pastille d'icône accentuée,
//  intitulé, explication concrète et état (cadenas / coche).
//

import SwiftUI

struct PremiumBenefitRow: View {
    let benefit: PremiumBenefit
    /// Vrai quand le premium est déjà acquis : le cadenas laisse place à la coche.
    var isUnlocked: Bool = false

    @EnvironmentObject private var localization: LocalizationManager
    @Environment(\.theme) private var theme

    var body: some View {
        HStack(alignment: .top, spacing: Theme.Spacing.medium) {
            iconTile

            VStack(alignment: .leading, spacing: Theme.Spacing.xSmall) {
                Text(localization.string(benefit.titleKey))
                    .font(.system(size: Theme.FontSize.body, weight: .semibold, design: .rounded))
                    .foregroundStyle(theme.primaryText)
                Text(localization.string(benefit.detailKey))
                    .font(.system(size: Theme.FontSize.caption))
                    .foregroundStyle(theme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)

            Image(systemName: isUnlocked ? "checkmark.circle.fill" : "lock.fill")
                .font(.system(size: Theme.FontSize.caption, weight: .bold))
                .foregroundStyle(isUnlocked ? theme.accent : theme.secondaryText.opacity(0.6))
                .padding(.top, Theme.Spacing.xSmall)
        }
    }

    private var iconTile: some View {
        Image(systemName: benefit.icon)
            .font(.system(size: Theme.FontSize.body, weight: .semibold))
            .foregroundStyle(theme.accent)
            .frame(width: Theme.Size.premiumBenefitIcon, height: Theme.Size.premiumBenefitIcon)
            .background(
                RoundedRectangle(cornerRadius: Theme.Radius.medium, style: .continuous)
                    .fill(theme.accent.opacity(0.14))
                    .overlay(
                        RoundedRectangle(cornerRadius: Theme.Radius.medium, style: .continuous)
                            .stroke(theme.accent.opacity(0.25), lineWidth: 1)
                    )
            )
    }
}

#Preview {
    VStack(spacing: Theme.Spacing.large) {
        ForEach(PremiumBenefit.all) { PremiumBenefitRow(benefit: $0) }
        PremiumBenefitRow(benefit: PremiumBenefit.all[0], isUnlocked: true)
    }
    .padding()
    .background(Color.grymBgDark)
    .environmentObject(LocalizationManager())
    .environment(\.theme, GrymBlueTheme())
}
