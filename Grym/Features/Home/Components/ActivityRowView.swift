//
//  ActivityRowView.swift
//  Grym
//
//  Ligne du flux « Activité récente » : vignette du jeu, icône + intitulé
//  de l'action, contexte, et date relative alignée à droite.
//

import SwiftUI

struct ActivityRowView: View {
    let entry: ActivityEntry

    @Environment(\.theme) private var theme

    var body: some View {
        HStack(alignment: .top, spacing: Theme.Spacing.medium) {
            WikiCoverView(
                imageId: nil,
                tint: entry.coverTint,
                cornerRadius: Theme.Radius.small
            )
            .frame(width: 44, height: 44)

            VStack(alignment: .leading, spacing: Theme.Spacing.xSmall) {
                HStack(spacing: Theme.Spacing.xSmall + 2) {
                    Image(systemName: entry.kind.systemImage)
                        .font(.system(size: Theme.FontSize.caption, weight: .semibold))
                        .foregroundStyle(theme.accent)
                    Text(entry.title)
                        .font(.system(size: Theme.FontSize.body - 1, weight: .semibold))
                        .foregroundStyle(theme.primaryText)
                }
                Text(entry.subtitle)
                    .font(.system(size: Theme.FontSize.caption, weight: .regular))
                    .foregroundStyle(theme.secondaryText)
                    .lineLimit(1)
            }

            Spacer(minLength: Theme.Spacing.small)

            Text(entry.date.relativeDescription)
                .font(.system(size: Theme.FontSize.caption, weight: .regular))
                .foregroundStyle(theme.secondaryText)
        }
        .padding(.vertical, Theme.Spacing.small + 2)
    }
}

#Preview {
    ActivityRowView(
        entry: ActivityEntry(
            kind: .checklist,
            title: "Added checklist",
            subtitle: "Elden Ring · Remembrance Bosses — 8 items",
            coverTint: Color(hex: 0xE0A458),
            date: Date().addingTimeInterval(-7200)
        )
    )
    .padding()
    .background(Color.grymBgDark)
    .environment(\.theme, GrymBlueTheme())
}
