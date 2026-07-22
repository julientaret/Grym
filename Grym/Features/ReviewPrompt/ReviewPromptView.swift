//
//  ReviewPromptView.swift
//  Grym
//
//  Demande de note façon écran de succès : proposée une seule fois, au
//  lancement suivant le passage du palier de jeux (cf. ReviewPromptManager).
//

import StoreKit
import SwiftUI

struct ReviewPromptView: View {
    @EnvironmentObject private var localization: LocalizationManager
    @Environment(\.theme) private var theme
    @Environment(\.dismiss) private var dismiss
    @Environment(\.requestReview) private var requestReview

    var body: some View {
        ZStack {
            // Même fond « menu de jeu » que le paywall : un seul langage visuel
            // pour les écrans qui interpellent le joueur.
            PremiumBackgroundView()

            VStack(spacing: Theme.Spacing.xLarge) {
                Spacer(minLength: 0)

                ReviewPromptHeaderView()
                ReviewStarsView()

                Spacer(minLength: 0)

                VStack(spacing: Theme.Spacing.small) {
                    rateButton

                    Text(localization.string(.reviewPromptFooter))
                        .font(.system(size: Theme.FontSize.caption))
                        .foregroundStyle(theme.secondaryText)
                        .multilineTextAlignment(.center)

                    laterButton
                }
            }
            .padding(.horizontal, Theme.Spacing.large)
            .padding(.vertical, Theme.Spacing.xLarge)
        }
    }

    // MARK: Actions

    private var rateButton: some View {
        Button(action: rate) {
            HStack(spacing: Theme.Spacing.small) {
                Image(systemName: "star.fill")
                    .font(.system(size: Theme.FontSize.caption, weight: .bold))
                Text(localization.string(.reviewPromptCTA))
            }
            .font(.system(size: Theme.FontSize.body, weight: .bold, design: .rounded))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, Theme.Spacing.medium)
            .background(
                RoundedRectangle(cornerRadius: Theme.Radius.large, style: .continuous)
                    .fill(LinearGradient(colors: [theme.accent, theme.accentAlt],
                                         startPoint: .topLeading, endPoint: .bottomTrailing))
                    .overlay(
                        RoundedRectangle(cornerRadius: Theme.Radius.large, style: .continuous)
                            .stroke(.white.opacity(0.25), lineWidth: 1)
                    )
            )
            .shadow(color: theme.accent.opacity(0.45), radius: 14, y: 8)
        }
    }

    private var laterButton: some View {
        Button {
            dismiss()
        } label: {
            Text(localization.string(.reviewPromptLater))
                .font(.system(size: Theme.FontSize.body, weight: .medium))
                .foregroundStyle(theme.secondaryText)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Theme.Spacing.small)
        }
    }

    /// Déclenche la fiche système d'évaluation, puis referme : la fermeture est
    /// différée, sinon la fiche serait présentée sur une vue en train de partir.
    private func rate() {
        requestReview()
        Task {
            try? await Task.sleep(for: .seconds(1))
            dismiss()
        }
    }
}

#Preview {
    ReviewPromptView()
        .environmentObject(LocalizationManager())
        .environment(\.theme, GrymBlueTheme())
}
