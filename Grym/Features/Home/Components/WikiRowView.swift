//
//  WikiRowView.swift
//  Grym
//
//  Ligne de la liste « Tous les wikis » : cover, titre, méta (année ·
//  plateforme), statistiques (blocs / photos / listes) et pastille de note.
//

import SwiftUI

struct WikiRowView: View {
    let wiki: WikiSummary

    @EnvironmentObject private var localization: LocalizationManager
    @Environment(\.theme) private var theme

    var body: some View {
        HStack(spacing: Theme.Spacing.medium) {
            WikiCoverView(
                imageId: wiki.coverImageId,
                tint: wiki.coverTint,
                size: .coverSmall,
                cornerRadius: Theme.Radius.medium,
                caption: wiki.title
            )
            .frame(width: 72, height: 72)

            VStack(alignment: .leading, spacing: Theme.Spacing.xSmall + 2) {
                Text(wiki.title)
                    .font(.system(size: Theme.FontSize.body, weight: .semibold))
                    .foregroundStyle(theme.primaryText)
                    .lineLimit(1)

                Text(metaLine)
                    .font(.system(size: Theme.FontSize.caption, weight: .regular))
                    .foregroundStyle(theme.secondaryText)

                HStack(spacing: Theme.Spacing.small) {
                    stat(wiki.blockCount, localization.string(.statBlocks), theme.accent)
                    stat(wiki.photoCount, localization.string(.statPhotos), theme.accentAlt)
                    stat(wiki.listCount, localization.string(.statLists), theme.brand)
                }
            }

            Spacer(minLength: Theme.Spacing.small)

            ScoreBadgeView(score: wiki.score)
        }
        .padding(Theme.Spacing.medium)
        .background(
            RoundedRectangle(cornerRadius: Theme.Radius.large, style: .continuous)
                .fill(theme.surface.opacity(0.35))
        )
    }

    // MARK: Sous-vues

    private func stat(_ count: Int, _ label: String, _ color: Color) -> some View {
        HStack(spacing: Theme.Spacing.xSmall) {
            Circle()
                .fill(color)
                .frame(width: 6, height: 6)
            Text("\(count) \(label)")
                .font(.system(size: Theme.FontSize.caption, weight: .regular))
                .foregroundStyle(theme.secondaryText)
        }
    }

    private var metaLine: String {
        wiki.year.map(String.init) ?? ""
    }
}

#Preview {
    WikiRowView(
        wiki: WikiSummary(
            title: "Elden Ring", coverTint: Color(hex: 0xE0A458),
            year: 2022,
            blockCount: 63, photoCount: 18, listCount: 9,
            score: 92, updatedAt: Date()
        )
    )
    .padding()
    .background(Color.grymBgDark)
    .environmentObject(LocalizationManager())
    .environment(\.theme, GrymBlueTheme())
}
