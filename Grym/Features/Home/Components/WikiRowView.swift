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

                HStack(spacing: Theme.Spacing.small) {
                    Text(metaLine)
                        .font(.system(size: Theme.FontSize.caption, weight: .regular))
                        .foregroundStyle(theme.secondaryText)

                    if wiki.status != .none {
                        GameStatusBadge(status: wiki.status, compact: true)
                            .accessibilityLabel(localization.string(wiki.status.nameKey))
                    }

                    if wiki.playMinutes > 0 {
                        Text(playtimeLabel)
                            .font(.system(size: Theme.FontSize.caption, weight: .medium))
                            .foregroundStyle(theme.secondaryText)
                    }
                }

                statsRow
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

    /// Compteurs de contenu : icône + nombre, les compteurs à zéro sont masqués
    /// pour ne garder que l'information utile sur une ligne dense.
    private var statsRow: some View {
        HStack(spacing: Theme.Spacing.small + 2) {
            stat("square.stack.3d.up.fill", wiki.blockCount,
                 localization.string(.statBlocks), theme.accent)
            stat("photo.fill", wiki.photoCount,
                 localization.string(.statPhotos), theme.accentAlt)
            stat("checklist", wiki.listCount,
                 localization.string(.statLists), theme.brand)
        }
    }

    @ViewBuilder
    private func stat(_ systemImage: String, _ count: Int,
                      _ label: String, _ color: Color) -> some View {
        if count > 0 {
            HStack(spacing: Theme.Spacing.xSmall) {
                Image(systemName: systemImage)
                    .font(.system(size: Theme.FontSize.caption - 2, weight: .semibold))
                    .foregroundStyle(color)
                Text("\(count)")
                    .font(.system(size: Theme.FontSize.caption, weight: .medium))
                    .foregroundStyle(theme.secondaryText)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("\(count) \(label)")
        }
    }

    private var metaLine: String {
        wiki.year.map(String.init) ?? ""
    }

    private var playtimeLabel: String {
        wiki.playMinutes.playtimeLabel(
            hourUnit: localization.string(.durationHourUnit),
            minuteUnit: localization.string(.durationMinuteUnit)
        )
    }
}

#Preview {
    WikiRowView(
        wiki: WikiSummary(
            title: "Elden Ring", coverTint: Color(hex: 0xE0A458),
            year: 2022,
            blockCount: 63, photoCount: 18, listCount: 9,
            score: 92, updatedAt: Date(), status: .playing, playMinutes: 1_260
        )
    )
    .padding()
    .background(Color.grymBgDark)
    .environmentObject(LocalizationManager())
    .environment(\.theme, GrymBlueTheme())
}
