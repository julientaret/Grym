//
//  EmptyStateView.swift
//  Grym
//
//  État vide réutilisable : badge illustré, titre, message explicatif,
//  étapes optionnelles et appel à l'action optionnel.
//  Placé dans Core car partagé par plusieurs features (Accueil, Mes jeux).
//

import SwiftUI

/// Une étape du « quoi faire ensuite » affichée sous le message.
struct EmptyStateStep: Identifiable {
    let id = UUID()
    let systemImage: String
    let text: String
}

struct EmptyStateView<Action: View>: View {
    let systemImage: String
    let title: String
    let message: String
    var steps: [EmptyStateStep] = []
    @ViewBuilder var action: Action

    @Environment(\.theme) private var theme

    var body: some View {
        VStack(spacing: Theme.Spacing.large) {
            iconBadge

            VStack(spacing: Theme.Spacing.small) {
                Text(title)
                    .font(.system(size: Theme.FontSize.title, weight: .bold))
                    .foregroundStyle(theme.primaryText)
                    .multilineTextAlignment(.center)

                Text(message)
                    .font(.system(size: Theme.FontSize.body - 1))
                    .foregroundStyle(theme.secondaryText)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if !steps.isEmpty {
                stepsCard
            }

            action
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, Theme.Spacing.large)
        .padding(.vertical, Theme.Spacing.xLarge)
    }

    // MARK: Badge illustré

    private var iconBadge: some View {
        ZStack {
            // Halo diffus derrière le badge.
            Circle()
                .fill(
                    RadialGradient(
                        colors: [theme.accent.opacity(0.35), .clear],
                        center: .center,
                        startRadius: 2,
                        endRadius: 62
                    )
                )
                .frame(width: 124, height: 124)

            Circle()
                .fill(theme.surface.opacity(0.6))
                .frame(width: 78, height: 78)
                .overlay(
                    Circle().stroke(
                        LinearGradient(
                            colors: [theme.accent.opacity(0.55), theme.accentAlt.opacity(0.25)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
                )

            Image(systemName: systemImage)
                .font(.system(size: 32, weight: .medium))
                .foregroundStyle(
                    LinearGradient(
                        colors: [theme.accent, theme.accentAlt],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        }
    }

    // MARK: Étapes

    private var stepsCard: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.medium) {
            ForEach(steps) { step in
                HStack(spacing: Theme.Spacing.medium) {
                    Image(systemName: step.systemImage)
                        .font(.system(size: Theme.FontSize.caption + 1, weight: .semibold))
                        .foregroundStyle(theme.accent)
                        .frame(width: 26, height: 26)
                        .background(Circle().fill(theme.accent.opacity(0.15)))

                    Text(step.text)
                        .font(.system(size: Theme.FontSize.caption + 1))
                        .foregroundStyle(theme.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)

                    Spacer(minLength: 0)
                }
            }
        }
        .padding(Theme.Spacing.medium)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: Theme.Radius.large, style: .continuous)
                .fill(theme.surface.opacity(0.45))
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.Radius.large, style: .continuous)
                        .stroke(.white.opacity(0.06), lineWidth: 1)
                )
        )
    }
}

// Variante sans appel à l'action.
extension EmptyStateView where Action == EmptyView {
    init(
        systemImage: String,
        title: String,
        message: String,
        steps: [EmptyStateStep] = []
    ) {
        self.init(
            systemImage: systemImage,
            title: title,
            message: message,
            steps: steps,
            action: { EmptyView() }
        )
    }
}

#Preview {
    ScrollView {
        EmptyStateView(
            systemImage: "gamecontroller",
            title: "Aucun jeu pour l'instant",
            message: "Ajoute ton premier jeu pour commencer ta collection.",
            steps: [
                EmptyStateStep(systemImage: "magnifyingglass", text: "Recherche un jeu dans le catalogue."),
                EmptyStateStep(systemImage: "doc.text", text: "Crée des wikis : notes, checklists, photos.")
            ]
        ) {
            WideAddGameButton(action: {})
        }

        EmptyStateView(
            systemImage: "pin",
            title: "Rien d'épinglé",
            message: "Épingle un jeu pour le retrouver ici."
        )
    }
    .background(Color.grymBgDark)
    .environmentObject(LocalizationManager())
    .environment(\.theme, GrymBlueTheme())
}
