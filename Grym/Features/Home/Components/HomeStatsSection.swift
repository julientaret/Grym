//
//  HomeStatsSection.swift
//  Grym
//
//  Section « Bilan » du dashboard : temps de jeu mis en avant, répartition
//  par statut et trois chiffres clés, avec accès au bilan complet.
//

import SwiftUI

struct HomeStatsSection: View {
    let stats: LibraryStats
    /// Vrai si le bilan détaillé est débloqué (sinon, badge premium).
    let isDetailUnlocked: Bool
    var onOpenDetail: () -> Void

    @EnvironmentObject private var localization: LocalizationManager
    @Environment(\.theme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.medium) {
            SectionHeaderView(
                systemImage: "chart.bar.fill",
                title: localization.string(.statsSection)
            )

            VStack(alignment: .leading, spacing: Theme.Spacing.large) {
                PlaytimeHeroView(
                    totalMinutes: stats.totalPlayMinutes,
                    sessionCount: stats.sessionCount,
                    averageMinutes: stats.averageSessionMinutes
                )

                if !stats.statusBreakdown.isEmpty {
                    VStack(alignment: .leading, spacing: Theme.Spacing.small) {
                        BreakdownBarView(slices: stats.statusBreakdown)
                        BreakdownChipsView(slices: stats.statusBreakdown)
                    }
                }

                keyFigures

                detailButton
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
        .padding(.horizontal, Theme.Spacing.large)
    }

    // MARK: Chiffres clés

    private var keyFigures: some View {
        HStack(spacing: Theme.Spacing.small) {
            figure(
                systemImage: "gamecontroller.fill",
                value: "\(stats.gameCount)",
                label: localization.string(.statsGames),
                color: theme.accent
            )
            figure(
                systemImage: "star.fill",
                value: stats.ratedCount == 0 ? "—" : "\(stats.averageScore)",
                label: localization.string(.statsAverageScore),
                color: theme.tier(for: stats.averageScore)
            )
            figure(
                systemImage: "book.pages.fill",
                value: "\(stats.pageCount)",
                label: localization.string(.statsPages),
                color: theme.accentAlt
            )
        }
    }

    private func figure(
        systemImage: String,
        value: String,
        label: String,
        color: Color
    ) -> some View {
        VStack(spacing: Theme.Spacing.xSmall) {
            Image(systemName: systemImage)
                .font(.system(size: Theme.FontSize.caption, weight: .bold))
                .foregroundStyle(color)

            Text(value)
                .font(.system(size: Theme.FontSize.title, weight: .bold))
                .foregroundStyle(theme.primaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.6)

            Text(label)
                .font(.system(size: Theme.FontSize.caption))
                .foregroundStyle(theme.secondaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Theme.Spacing.medium)
        .background(
            RoundedRectangle(cornerRadius: Theme.Radius.medium, style: .continuous)
                .fill(theme.surface.opacity(0.6))
                .overlay(alignment: .top) {
                    // Filet coloré : rattache visuellement la tuile à sa donnée.
                    Rectangle()
                        .fill(color.opacity(0.8))
                        .frame(height: 2)
                        .clipShape(Capsule())
                        .padding(.horizontal, Theme.Spacing.large)
                }
        )
    }

    // MARK: Accès au bilan complet

    private var detailButton: some View {
        Button(action: onOpenDetail) {
            HStack(spacing: Theme.Spacing.small) {
                Text(localization.string(.statsSeeAll))
                    .font(.system(size: Theme.FontSize.caption, weight: .semibold))
                    .foregroundStyle(theme.accent)

                Spacer()

                if isDetailUnlocked {
                    Image(systemName: "chevron.right")
                        .font(.system(size: Theme.FontSize.caption, weight: .bold))
                        .foregroundStyle(theme.accent)
                } else {
                    Text(localization.string(.profileThemePremium))
                        .font(.system(size: Theme.FontSize.caption, weight: .bold))
                        .foregroundStyle(theme.accent)
                        .padding(.horizontal, Theme.Spacing.small)
                        .padding(.vertical, Theme.Spacing.xSmall)
                        .background(Capsule().fill(theme.accent.opacity(0.15)))
                }
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    var stats = LibraryStats()
    stats.gameCount = 24
    stats.pageCount = 63
    stats.sessionCount = 48
    stats.totalPlayMinutes = 18_720
    stats.averageScore = 86
    stats.ratedCount = 20
    stats.statusBreakdown = [
        BreakdownSlice(id: "a", nameKey: .statusPlaying, color: .grymStatusPlaying, count: 3),
        BreakdownSlice(id: "b", nameKey: .statusCompleted, color: .grymStatusCompleted, count: 9),
        BreakdownSlice(id: "c", nameKey: .statusBacklog, color: .grymStatusBacklog, count: 12)
    ]

    return HomeStatsSection(stats: stats, isDetailUnlocked: false, onOpenDetail: {})
        .padding(.vertical)
        .background(Color.grymBgDark)
        .environmentObject(LocalizationManager())
        .environment(\.theme, GrymBlueTheme())
}
