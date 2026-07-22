//
//  RateAppCard.swift
//  Grym
//
//  Encart du Profil pour noter l'app : même ton que la demande proposée au
//  4e jeu, mais déclenché volontairement. Ouvre la fiche système d'évaluation.
//

import StoreKit
import SwiftUI

struct RateAppCard: View {
    @EnvironmentObject private var localization: LocalizationManager
    @Environment(\.theme) private var theme
    @Environment(\.requestReview) private var requestReview

    var body: some View {
        Button {
            requestReview()
        } label: {
            HStack(spacing: Theme.Spacing.medium) {
                icon

                VStack(alignment: .leading, spacing: Theme.Spacing.xSmall) {
                    Text(localization.string(.reviewPromptCTA))
                        .font(.system(size: Theme.FontSize.body, weight: .semibold))
                        .foregroundStyle(theme.primaryText)
                    Text(localization.string(.profileRateMessage))
                        .font(.system(size: Theme.FontSize.caption))
                        .foregroundStyle(theme.secondaryText)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                    stars
                }

                Spacer(minLength: 0)

                Image(systemName: "chevron.right")
                    .font(.system(size: Theme.FontSize.caption, weight: .semibold))
                    .foregroundStyle(theme.secondaryText)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private var icon: some View {
        Image(systemName: "star.fill")
            .font(.system(size: Theme.FontSize.body, weight: .semibold))
            .foregroundStyle(.white)
            .frame(width: Theme.Size.premiumBenefitIcon, height: Theme.Size.premiumBenefitIcon)
            .background(
                RoundedRectangle(cornerRadius: Theme.Radius.medium, style: .continuous)
                    .fill(LinearGradient(colors: [theme.accent, theme.accentAlt],
                                         startPoint: .topLeading, endPoint: .bottomTrailing))
            )
    }

    /// Rappel discret des cinq étoiles de la modale (décoratif).
    private var stars: some View {
        HStack(spacing: Theme.Spacing.xSmall / 2) {
            ForEach(0..<5, id: \.self) { _ in
                Image(systemName: "star.fill")
                    .font(.system(size: Theme.FontSize.caption - 2))
                    .foregroundStyle(theme.accent)
            }
        }
        .padding(.top, Theme.Spacing.xSmall / 2)
        .accessibilityHidden(true)
    }
}

#Preview {
    RateAppCard()
        .padding()
        .background(Color.grymBgDark)
        .environmentObject(LocalizationManager())
        .environment(\.theme, GrymBlueTheme())
}
