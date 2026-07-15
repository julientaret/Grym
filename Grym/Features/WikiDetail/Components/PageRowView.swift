//
//  PageRowView.swift
//  Grym
//
//  Ligne d'une page dans le détail d'un wiki : icône, titre,
//  nombre de blocs et date de modification.
//

import SwiftUI

struct PageRowView: View {
    let title: String
    let blockCount: Int
    let accent: Color

    @EnvironmentObject private var localization: LocalizationManager
    @Environment(\.theme) private var theme

    var body: some View {
        HStack(spacing: Theme.Spacing.medium) {
            RoundedRectangle(cornerRadius: Theme.Radius.small, style: .continuous)
                .fill(accent.opacity(0.25))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: "doc.text")
                        .font(.system(size: Theme.FontSize.body, weight: .semibold))
                        .foregroundStyle(accent)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: Theme.FontSize.body, weight: .semibold))
                    .foregroundStyle(theme.primaryText)
                    .lineLimit(1)
                Text("\(blockCount) \(localization.string(.statBlocks))")
                    .font(.system(size: Theme.FontSize.caption, weight: .regular))
                    .foregroundStyle(theme.secondaryText)
            }

            Spacer(minLength: Theme.Spacing.small)
        }
        .padding(Theme.Spacing.medium)
        .background(
            RoundedRectangle(cornerRadius: Theme.Radius.medium, style: .continuous)
                .fill(theme.surface.opacity(0.4))
                .overlay(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(accent)
                        .frame(width: 3)
                        .padding(.vertical, Theme.Spacing.small)
                }
        )
    }
}

#Preview {
    PageRowView(title: "Biome Log", blockCount: 19, accent: .grymAccent)
        .padding()
        .background(Color.grymBgDark)
        .environmentObject(LocalizationManager())
        .environment(\.theme, GrymBlueTheme())
}
