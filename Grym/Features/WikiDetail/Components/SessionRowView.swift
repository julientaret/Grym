//
//  SessionRowView.swift
//  Grym
//
//  Ligne d'une session dans le journal d'un wiki : ressenti, date,
//  durée et note libre.
//

import SwiftUI

struct SessionRowView: View {
    let session: PlaySession

    @EnvironmentObject private var localization: LocalizationManager
    @Environment(\.theme) private var theme

    var body: some View {
        HStack(alignment: .top, spacing: Theme.Spacing.medium) {
            Image(systemName: session.mood.systemImage)
                .font(.system(size: Theme.FontSize.body, weight: .semibold))
                .foregroundStyle(session.mood.color)
                .frame(width: Theme.Size.sessionMoodIcon, height: Theme.Size.sessionMoodIcon)
                .background(
                    Circle().fill(session.mood.color.opacity(0.15))
                )

            VStack(alignment: .leading, spacing: Theme.Spacing.xSmall) {
                HStack(spacing: Theme.Spacing.small) {
                    Text(dateLabel)
                        .font(.system(size: Theme.FontSize.body, weight: .semibold))
                        .foregroundStyle(theme.primaryText)
                    Text(durationLabel)
                        .font(.system(size: Theme.FontSize.caption, weight: .semibold))
                        .foregroundStyle(theme.accent)
                }

                if !session.note.isEmpty {
                    Text(session.note)
                        .font(.system(size: Theme.FontSize.caption, weight: .regular))
                        .foregroundStyle(theme.secondaryText)
                        .lineLimit(3)
                }
            }

            Spacer(minLength: 0)
        }
        .padding(.vertical, Theme.Spacing.small)
    }

    private var dateLabel: String {
        session.date.formatted(date: .abbreviated, time: .omitted)
    }

    private var durationLabel: String {
        session.minutes.playtimeLabel(
            hourUnit: localization.string(.durationHourUnit),
            minuteUnit: localization.string(.durationMinuteUnit)
        )
    }
}

#Preview {
    SessionRowView(
        session: PlaySession(minutes: 150, mood: .hyped, note: "Boss final du chapitre 2, enfin.")
    )
    .padding()
    .background(Color.grymBgDark)
    .environmentObject(LocalizationManager())
    .environment(\.theme, GrymBlueTheme())
}
