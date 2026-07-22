//
//  PlaytimeHeroView.swift
//  Grym
//
//  En-tête du bilan : temps de jeu cumulé en très gros, résumé des sessions
//  et pastille d'icône. Partagé par le résumé de l'accueil et l'écran complet.
//

import SwiftUI

struct PlaytimeHeroView: View {
    let totalMinutes: Int
    let sessionCount: Int
    let averageMinutes: Int

    @EnvironmentObject private var localization: LocalizationManager
    @Environment(\.theme) private var theme

    var body: some View {
        HStack(spacing: Theme.Spacing.medium) {
            VStack(alignment: .leading, spacing: Theme.Spacing.xSmall) {
                Text(localization.string(.statsPlaytime).uppercased())
                    .font(.system(size: Theme.FontSize.caption, weight: .semibold))
                    .foregroundStyle(theme.secondaryText)
                    .tracking(1)

                Text(playtime(totalMinutes))
                    .font(.system(size: Theme.FontSize.hero, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [theme.accent, theme.accentAlt],
                            startPoint: .leading, endPoint: .trailing
                        )
                    )
                    .contentTransition(.numericText())
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)

                Text(summary)
                    .font(.system(size: Theme.FontSize.caption))
                    .foregroundStyle(theme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)

            Image(systemName: "hourglass")
                .font(.system(size: Theme.FontSize.title, weight: .semibold))
                .foregroundStyle(theme.accent)
                .frame(width: Theme.Size.statsHeroIcon, height: Theme.Size.statsHeroIcon)
                .background(Circle().fill(theme.accent.opacity(0.12)))
        }
    }

    /// Sans session, le gros « 0 » appelle une invitation plutôt qu'un décompte.
    private var summary: String {
        guard sessionCount > 0 else { return localization.string(.statsNoSessionHint) }
        let sessions = "\(sessionCount) \(localization.string(.sessionsCount))"
        return "\(sessions) · \(playtime(averageMinutes)) \(localization.string(.statsOnAverage))"
    }

    private func playtime(_ minutes: Int) -> String {
        minutes.playtimeLabel(
            hourUnit: localization.string(.durationHourUnit),
            minuteUnit: localization.string(.durationMinuteUnit)
        )
    }
}

#Preview {
    VStack(spacing: Theme.Spacing.xLarge) {
        PlaytimeHeroView(totalMinutes: 18_720, sessionCount: 48, averageMinutes: 390)
        PlaytimeHeroView(totalMinutes: 0, sessionCount: 0, averageMinutes: 0)
    }
    .padding()
    .background(Color.grymBgDark)
    .environmentObject(LocalizationManager())
    .environment(\.theme, GrymBlueTheme())
}
