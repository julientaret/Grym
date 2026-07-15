//
//  GameSearchResultRow.swift
//  Grym
//
//  Ligne de résultat de recherche IGDB : cover, titre, année · plateforme.
//

import SwiftUI

struct GameSearchResultRow: View {
    let game: IGDBGame

    @Environment(\.theme) private var theme

    var body: some View {
        HStack(spacing: Theme.Spacing.medium) {
            WikiCoverView(
                imageId: game.cover?.imageId,
                tint: theme.accentAlt,
                size: .coverSmall,
                cornerRadius: Theme.Radius.small
            )
            .frame(width: 52, height: 70)

            VStack(alignment: .leading, spacing: Theme.Spacing.xSmall) {
                Text(game.name)
                    .font(.system(size: Theme.FontSize.body, weight: .semibold))
                    .foregroundStyle(theme.primaryText)
                    .lineLimit(2)

                if let meta = metaLine {
                    Text(meta)
                        .font(.system(size: Theme.FontSize.caption, weight: .regular))
                        .foregroundStyle(theme.secondaryText)
                }
            }

            Spacer(minLength: Theme.Spacing.small)

            Image(systemName: "plus.circle.fill")
                .font(.system(size: Theme.FontSize.title, weight: .regular))
                .foregroundStyle(theme.accent)
        }
        .padding(.vertical, Theme.Spacing.small)
        .contentShape(Rectangle())
    }

    private var metaLine: String? {
        let parts = [game.releaseYear.map(String.init), game.primaryPlatform].compactMap { $0 }
        return parts.isEmpty ? nil : parts.joined(separator: " · ")
    }
}

#Preview {
    GameSearchResultRow(
        game: IGDBGame(
            id: 1, name: "Elden Ring", slug: "elden-ring",
            firstReleaseDate: 1_645_747_200,
            cover: IGDBCover(id: nil, imageId: "co4jni"),
            platforms: [IGDBPlatform(id: 167, name: "PlayStation 5", abbreviation: "PS5")]
        )
    )
    .padding()
    .background(Color.grymBgDark)
    .environment(\.theme, GrymBlueTheme())
}
