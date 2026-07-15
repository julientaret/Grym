//
//  AllWikisSection.swift
//  Grym
//
//  Section « Tous les wikis · N » : en-tête avec compteur + liste des wikis.
//

import SwiftUI

struct AllWikisSection: View {
    let wikis: [WikiSummary]

    @EnvironmentObject private var localization: LocalizationManager
    @Environment(\.theme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.medium) {
            HStack(spacing: Theme.Spacing.xSmall + 2) {
                Text(localization.string(.homeAllWikis))
                    .font(.system(size: Theme.FontSize.body, weight: .semibold))
                    .foregroundStyle(theme.primaryText)
                Text("· \(wikis.count)")
                    .font(.system(size: Theme.FontSize.body, weight: .semibold))
                    .foregroundStyle(theme.secondaryText)
            }

            if wikis.isEmpty {
                emptyState
            } else {
                LazyVStack(spacing: Theme.Spacing.small) {
                    ForEach(wikis) { wiki in
                        WikiRowView(wiki: wiki)
                    }
                }
            }
        }
        .padding(.horizontal, Theme.Spacing.large)
    }

    private var emptyState: some View {
        VStack(spacing: Theme.Spacing.medium) {
            Image(systemName: "gamecontroller")
                .font(.system(size: Theme.FontSize.largeTitle))
                .foregroundStyle(theme.secondaryText.opacity(0.7))
            Text(localization.string(.homeEmptyWikis))
                .font(.system(size: Theme.FontSize.body))
                .foregroundStyle(theme.secondaryText)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Theme.Spacing.xLarge)
    }
}

#Preview {
    AllWikisSection(
        wikis: [
            WikiSummary(title: "Elden Ring", coverTint: Color(hex: 0xE0A458),
                        year: 2022, platform: "PS5", blockCount: 63, photoCount: 18,
                        listCount: 9, score: 92, updatedAt: Date()),
            WikiSummary(title: "Subnautica", coverTint: Color(hex: 0x2FA9D8),
                        year: 2018, platform: "PC", blockCount: 47, photoCount: 24,
                        listCount: 5, score: 76, updatedAt: Date())
        ]
    )
    .padding(.vertical)
    .background(Color.grymBgDark)
    .environmentObject(LocalizationManager())
    .environment(\.theme, GrymBlueTheme())
}
