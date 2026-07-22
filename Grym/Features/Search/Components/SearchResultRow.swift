//
//  SearchResultRow.swift
//  Grym
//
//  Ligne d'un résultat de recherche : jaquette, extrait et contexte.
//

import SwiftData
import SwiftUI

struct SearchResultRow: View {
    let result: SearchResult

    @Environment(\.theme) private var theme

    var body: some View {
        HStack(spacing: Theme.Spacing.medium) {
            WikiCoverView(
                imageId: result.coverImageId,
                tint: result.coverTint,
                size: .coverSmall,
                cornerRadius: Theme.Radius.small
            )
            .frame(width: Theme.Size.searchThumbnail, height: Theme.Size.searchThumbnail)

            VStack(alignment: .leading, spacing: Theme.Spacing.xSmall) {
                Text(result.title)
                    .font(.system(size: Theme.FontSize.body, weight: .medium))
                    .foregroundStyle(theme.primaryText)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                if !result.subtitle.isEmpty {
                    Text(result.subtitle)
                        .font(.system(size: Theme.FontSize.caption))
                        .foregroundStyle(theme.secondaryText)
                        .lineLimit(1)
                }
            }

            Spacer(minLength: 0)

            Image(systemName: result.kind.systemImage)
                .font(.system(size: Theme.FontSize.caption, weight: .semibold))
                .foregroundStyle(theme.accent.opacity(0.7))
        }
        .padding(.vertical, Theme.Spacing.xSmall)
    }
}

#Preview {
    SearchResultRow(result: SearchResult(
        kind: .text,
        title: "…emplacement des Larmes Écarlates dans la crypte…",
        subtitle: "Elden Ring · Objets",
        coverImageId: nil,
        coverTint: Color(hex: 0xE0A458),
        wikiID: PreviewSampleData.sampleWiki.persistentModelID,
        pageID: nil
    ))
    .padding()
    .background(Color.grymBgDark)
    .environment(\.theme, GrymBlueTheme())
}
