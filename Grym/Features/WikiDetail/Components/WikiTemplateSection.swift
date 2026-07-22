//
//  WikiTemplateSection.swift
//  Grym
//
//  Proposition de modèles de démarrage, affichée tant que le jeu n'a
//  aucun wiki. Chaque carte crée d'un coup les pages du modèle.
//

import SwiftUI

struct WikiTemplateSection: View {
    var onSelect: (WikiTemplate) -> Void

    @EnvironmentObject private var localization: LocalizationManager
    @Environment(\.theme) private var theme

    private let columns = [
        GridItem(.flexible(), spacing: Theme.Spacing.medium),
        GridItem(.flexible(), spacing: Theme.Spacing.medium)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.medium) {
            VStack(alignment: .leading, spacing: Theme.Spacing.xSmall) {
                Text(localization.string(.templateSectionTitle))
                    .font(.system(size: Theme.FontSize.body, weight: .semibold))
                    .foregroundStyle(theme.primaryText)
                Text(localization.string(.templateSectionHint))
                    .font(.system(size: Theme.FontSize.caption))
                    .foregroundStyle(theme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }

            LazyVGrid(columns: columns, spacing: Theme.Spacing.medium) {
                ForEach(WikiTemplate.allCases) { template in
                    Button { onSelect(template) } label: {
                        card(for: template)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(Theme.Spacing.large)
        .background(
            RoundedRectangle(cornerRadius: Theme.Radius.large, style: .continuous)
                .fill(theme.surface.opacity(0.5))
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.Radius.large, style: .continuous)
                        .stroke(.white.opacity(0.06), lineWidth: 1)
                )
        )
    }

    private func card(for template: WikiTemplate) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xSmall) {
            Image(systemName: template.systemImage)
                .font(.system(size: Theme.FontSize.body, weight: .semibold))
                .foregroundStyle(theme.accent)

            Text(localization.string(template.nameKey))
                .font(.system(size: Theme.FontSize.caption, weight: .bold))
                .foregroundStyle(theme.primaryText)

            Text(localization.string(template.descriptionKey))
                .font(.system(size: Theme.FontSize.caption))
                .foregroundStyle(theme.secondaryText)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Theme.Spacing.medium)
        .background(
            RoundedRectangle(cornerRadius: Theme.Radius.medium, style: .continuous)
                .fill(theme.surface.opacity(0.6))
        )
    }
}

#Preview {
    WikiTemplateSection(onSelect: { _ in })
        .padding()
        .background(Color.grymBgDark)
        .environmentObject(LocalizationManager())
        .environment(\.theme, GrymBlueTheme())
}
