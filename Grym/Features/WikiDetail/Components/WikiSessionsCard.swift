//
//  WikiSessionsCard.swift
//  Grym
//
//  Carte « Sessions » du détail d'un wiki : temps de jeu cumulé, nombre de
//  sessions, journal des dernières parties et ajout d'une session.
//

import SwiftUI

struct WikiSessionsCard: View {
    let sessions: [PlaySession]
    var onAdd: () -> Void
    var onEdit: (PlaySession) -> Void
    var onDelete: (PlaySession) -> Void

    @EnvironmentObject private var localization: LocalizationManager
    @Environment(\.theme) private var theme

    /// Le journal est tronqué par défaut : évite d'étirer la page.
    @State private var showsAll = false

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.medium) {
            header

            if sessions.isEmpty {
                Text(localization.string(.sessionsEmpty))
                    .font(.system(size: Theme.FontSize.caption, weight: .regular))
                    .foregroundStyle(theme.secondaryText)
            } else {
                VStack(spacing: 0) {
                    ForEach(visibleSessions) { session in
                        Button { onEdit(session) } label: {
                            SessionRowView(session: session)
                        }
                        .buttonStyle(.plain)
                        .contextMenu {
                            Button(role: .destructive) {
                                onDelete(session)
                            } label: {
                                Label(localization.string(.commonDelete), systemImage: "trash")
                            }
                        }

                        if session.id != visibleSessions.last?.id {
                            Divider().overlay(theme.secondaryText.opacity(0.15))
                        }
                    }
                }

                if sessions.count > Theme.Limit.visibleSessions {
                    Button {
                        withAnimation(.snappy) { showsAll.toggle() }
                    } label: {
                        Text(localization.string(showsAll ? .sessionsShowLess : .sessionsShowAll))
                            .font(.system(size: Theme.FontSize.caption, weight: .semibold))
                            .foregroundStyle(theme.accent)
                    }
                }
            }

            addButton
        }
        .padding(Theme.Spacing.large)
        .background(
            RoundedRectangle(cornerRadius: Theme.Radius.large, style: .continuous)
                .fill(theme.surface.opacity(0.5))
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.Radius.large, style: .continuous)
                        .stroke(.white.opacity(0.06), lineWidth: 1)
                )
        )
    }

    // MARK: En-tête

    private var header: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: Theme.Spacing.xSmall) {
                Text(localization.string(.sessionsTotal).uppercased())
                    .font(.system(size: Theme.FontSize.caption, weight: .semibold))
                    .foregroundStyle(theme.secondaryText)
                    .tracking(1)

                Text(totalLabel)
                    .font(.system(size: Theme.FontSize.title, weight: .bold))
                    .foregroundStyle(theme.primaryText)
                    .contentTransition(.numericText())
            }

            Spacer()

            Text("\(sessions.count) \(localization.string(.sessionsCount))")
                .font(.system(size: Theme.FontSize.caption, weight: .medium))
                .foregroundStyle(theme.secondaryText)
        }
    }

    private var addButton: some View {
        Button(action: onAdd) {
            HStack(spacing: Theme.Spacing.xSmall) {
                Image(systemName: "plus.circle.fill")
                Text(localization.string(.sessionsAdd))
            }
            .font(.system(size: Theme.FontSize.caption, weight: .semibold))
            .foregroundStyle(theme.accent)
        }
    }

    // MARK: Données dérivées

    private var visibleSessions: [PlaySession] {
        showsAll ? sessions : Array(sessions.prefix(Theme.Limit.visibleSessions))
    }

    private var totalLabel: String {
        sessions.reduce(0) { $0 + $1.minutes }.playtimeLabel(
            hourUnit: localization.string(.durationHourUnit),
            minuteUnit: localization.string(.durationMinuteUnit)
        )
    }
}

#Preview {
    WikiSessionsCard(
        sessions: [
            PlaySession(minutes: 150, mood: .hyped, note: "Boss final du chapitre 2."),
            PlaySession(date: .now.addingTimeInterval(-86_400), minutes: 45, mood: .rough)
        ],
        onAdd: {}, onEdit: { _ in }, onDelete: { _ in }
    )
    .padding()
    .background(Color.grymBgDark)
    .environmentObject(LocalizationManager())
    .environment(\.theme, GrymBlueTheme())
}
