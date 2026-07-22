//
//  RankingSection.swift
//  Grym
//
//  Classement de tête du bilan (meilleures notes, temps de jeu) :
//  rang, jaquette, titre et valeur.
//

import SwiftUI

struct RankingSection: View {
    let title: String
    let games: [RankedGame]

    @Environment(\.theme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.medium) {
            Text(title.uppercased())
                .font(.system(size: Theme.FontSize.caption, weight: .semibold))
                .foregroundStyle(theme.secondaryText)
                .tracking(1)

            ForEach(Array(games.enumerated()), id: \.element.id) { index, game in
                HStack(spacing: Theme.Spacing.medium) {
                    Text("\(index + 1)")
                        .font(.system(size: Theme.FontSize.caption, weight: .bold))
                        .foregroundStyle(theme.secondaryText)
                        .frame(width: Theme.Spacing.medium)

                    WikiCoverView(
                        imageId: game.coverImageId,
                        tint: game.coverTint,
                        size: .coverSmall,
                        cornerRadius: Theme.Radius.small
                    )
                    .frame(width: Theme.Size.rankingThumbnail,
                           height: Theme.Size.rankingThumbnail)

                    Text(game.title)
                        .font(.system(size: Theme.FontSize.caption, weight: .medium))
                        .foregroundStyle(theme.primaryText)
                        .lineLimit(1)

                    Spacer(minLength: Theme.Spacing.small)

                    Text(game.value)
                        .font(.system(size: Theme.FontSize.caption, weight: .bold))
                        .foregroundStyle(theme.accent)
                }
            }
        }
        .padding(Theme.Spacing.large)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: Theme.Radius.large, style: .continuous)
                .fill(theme.surface.opacity(0.5))
        )
    }
}

#Preview {
    RankingSection(
        title: "Mieux notés",
        games: [
            RankedGame(id: "1", title: "Elden Ring", coverImageId: nil,
                       coverTint: Color(hex: 0xE0A458), value: "92"),
            RankedGame(id: "2", title: "Baldur's Gate 3", coverImageId: nil,
                       coverTint: Color(hex: 0x7C6FF0), value: "88")
        ]
    )
    .padding()
    .background(Color.grymBgDark)
    .environment(\.theme, GrymBlueTheme())
}
