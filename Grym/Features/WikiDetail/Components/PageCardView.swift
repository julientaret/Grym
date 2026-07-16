//
//  PageCardView.swift
//  Grym
//
//  Carte d'une page (mode « Cartes » du détail wiki) : titre, nombre
//  de blocs, accent coloré.
//

import SwiftUI

struct PageCardView: View {
    let title: String
    let blockCount: Int
    let accent: Color

    @EnvironmentObject private var localization: LocalizationManager
    @Environment(\.theme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.small) {
            RoundedRectangle(cornerRadius: Theme.Radius.small, style: .continuous)
                .fill(accent.opacity(0.25))
                .frame(width: 36, height: 36)
                .overlay(
                    Image(systemName: "doc.text")
                        .font(.system(size: Theme.FontSize.body, weight: .semibold))
                        .foregroundStyle(accent)
                )

            Text(title)
                .font(.system(size: Theme.FontSize.body, weight: .semibold))
                .foregroundStyle(theme.primaryText)
                .lineLimit(2)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text("\(blockCount) \(localization.string(.statBlocks))")
                .font(.system(size: Theme.FontSize.caption, weight: .regular))
                .foregroundStyle(theme.secondaryText)
        }
        .padding(Theme.Spacing.medium)
        .frame(maxWidth: .infinity, minHeight: 110, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: Theme.Radius.medium, style: .continuous)
                .fill(theme.surface.opacity(0.4))
                .overlay(alignment: .top) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(accent)
                        .frame(height: 3)
                        .padding(.horizontal, Theme.Spacing.medium)
                }
        )
    }
}

#Preview {
    HStack {
        PageCardView(title: "Biome Log", blockCount: 19, accent: .grymAccent)
        PageCardView(title: "Base Blueprints", blockCount: 6, accent: .grymAccentViolet)
    }
    .padding()
    .background(Color.grymBgDark)
    .environmentObject(LocalizationManager())
    .environment(\.theme, GrymBlueTheme())
}
