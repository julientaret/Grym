//
//  StatsView.swift
//  Grym
//
//  Bilan personnel : chiffres clés de la collection, répartition par statut
//  et par palier de note, classements de tête.
//

import SwiftData
import SwiftUI

struct StatsView: View {
    @StateObject private var viewModel = StatsViewModel()

    @EnvironmentObject private var localization: LocalizationManager
    @Environment(\.theme) private var theme
    @Environment(\.modelContext) private var modelContext

    private let columns = [
        GridItem(.flexible(), spacing: Theme.Spacing.medium),
        GridItem(.flexible(), spacing: Theme.Spacing.medium)
    ]
    /// Les volumes de contenu sont plus courts : trois par ligne.
    private let contentColumns = Array(
        repeating: GridItem(.flexible(), spacing: Theme.Spacing.small),
        count: 3
    )

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: Theme.Spacing.large) {
                if viewModel.stats.isEmpty {
                    emptyState
                } else {
                    hero
                    keyFigures
                    breakdowns
                    rankings
                    contentFigures
                }
            }
            .padding(.horizontal, Theme.Spacing.large)
            .padding(.bottom, Theme.Spacing.xLarge)
        }
        .background(background)
        .navigationTitle(localization.string(.statsTitle))
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { viewModel.load(context: modelContext, localization: localization) }
    }

    // MARK: En-tête

    private var hero: some View {
        PlaytimeHeroView(
            totalMinutes: viewModel.stats.totalPlayMinutes,
            sessionCount: viewModel.stats.sessionCount,
            averageMinutes: viewModel.stats.averageSessionMinutes
        )
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

    // MARK: Chiffres clés

    private var keyFigures: some View {
        LazyVGrid(columns: columns, spacing: Theme.Spacing.medium) {
            StatTileView(
                systemImage: "gamecontroller",
                value: "\(viewModel.stats.gameCount)",
                label: localization.string(.statsGames)
            )
            StatTileView(
                systemImage: "book.pages",
                value: "\(viewModel.stats.pageCount)",
                label: localization.string(.statsPages)
            )
            StatTileView(
                systemImage: "star.fill",
                value: viewModel.stats.ratedCount == 0 ? "—" : "\(viewModel.stats.averageScore)",
                label: localization.string(.statsAverageScore),
                accent: theme.tier(for: viewModel.stats.averageScore)
            )
            StatTileView(
                systemImage: "clock.arrow.circlepath",
                value: "\(viewModel.stats.sessionCount)",
                label: localization.string(.statsSessions)
            )
        }
    }

    // MARK: Répartitions

    @ViewBuilder
    private var breakdowns: some View {
        if !viewModel.stats.statusBreakdown.isEmpty {
            StatsBreakdownView(
                title: localization.string(.statsByStatus),
                slices: viewModel.stats.statusBreakdown
            )
        }
        if !viewModel.stats.tierBreakdown.isEmpty {
            StatsBreakdownView(
                title: localization.string(.statsByTier),
                slices: viewModel.stats.tierBreakdown
            )
        }
    }

    // MARK: Classements

    @ViewBuilder
    private var rankings: some View {
        if !viewModel.stats.topRated.isEmpty {
            RankingSection(
                title: localization.string(.statsTopRated),
                games: viewModel.stats.topRated
            )
        }
        if !viewModel.stats.mostPlayed.isEmpty {
            RankingSection(
                title: localization.string(.statsMostPlayed),
                games: viewModel.stats.mostPlayed
            )
        }
    }

    // MARK: Contenus créés

    private var contentFigures: some View {
        LazyVGrid(columns: contentColumns, spacing: Theme.Spacing.medium) {
            StatTileView(
                systemImage: "square.stack",
                value: "\(viewModel.stats.blockCount)",
                label: localization.string(.statBlocks),
                accent: theme.accentAlt
            )
            StatTileView(
                systemImage: "photo.on.rectangle",
                value: "\(viewModel.stats.photoCount)",
                label: localization.string(.statPhotos),
                accent: theme.brand
            )
            StatTileView(
                systemImage: "checklist",
                value: "\(viewModel.stats.checklistCount)",
                label: localization.string(.statLists),
                accent: theme.brand
            )
        }
    }

    // MARK: État vide

    private var emptyState: some View {
        EmptyStateView(
            systemImage: "chart.bar",
            title: localization.string(.statsEmptyTitle),
            message: localization.string(.statsEmptyMessage),
            steps: []
        )
    }

    // MARK: Fond

    private var background: some View {
        LinearGradient(
            colors: [theme.backgroundDeep, theme.background],
            startPoint: .top, endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}

#Preview {
    NavigationStack {
        StatsView()
    }
    .modelContainer(PreviewSampleData.container)
    .environmentObject(LocalizationManager())
    .environment(\.theme, GrymBlueTheme())
}
