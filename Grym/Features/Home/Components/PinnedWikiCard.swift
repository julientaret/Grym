//
//  PinnedWikiCard.swift
//  Grym
//
//  Carte d'un wiki épinglé : cover verticale avec titre incrusté,
//  puis nom du jeu et date de dernière modification en dessous.
//

import SwiftUI

struct PinnedWikiCard: View {
    let wiki: WikiSummary

    @Environment(\.theme) private var theme

    private let cardWidth: CGFloat = 132
    private let cardHeight: CGFloat = 168

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.small) {
            WikiCoverView(
                coverURL: wiki.coverURL,
                tint: wiki.coverTint,
                cornerRadius: Theme.Radius.large
            )
            .frame(width: cardWidth, height: cardHeight)
            .overlay(alignment: .bottomLeading) {
                Text(wiki.title)
                    .font(.system(size: Theme.FontSize.body + 2, weight: .bold))
                    .foregroundStyle(.white)
                    .lineLimit(2)
                    .shadow(color: .black.opacity(0.5), radius: 6, y: 2)
                    .padding(Theme.Spacing.small + 2)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(wiki.title)
                    .font(.system(size: Theme.FontSize.caption + 1, weight: .semibold))
                    .foregroundStyle(theme.primaryText)
                    .lineLimit(1)
                Text(wiki.updatedAt.relativeDescription)
                    .font(.system(size: Theme.FontSize.caption, weight: .regular))
                    .foregroundStyle(theme.secondaryText)
            }
            .frame(width: cardWidth, alignment: .leading)
        }
    }
}

#Preview {
    PinnedWikiCard(
        wiki: WikiSummary(
            title: "Elden Ring", coverTint: Color(hex: 0xE0A458),
            year: 2022, platform: "PS5",
            blockCount: 63, photoCount: 18, listCount: 9,
            score: 92, updatedAt: Date().addingTimeInterval(-7200)
        )
    )
    .padding()
    .background(Color.grymBgDark)
    .environment(\.theme, GrymBlueTheme())
}
