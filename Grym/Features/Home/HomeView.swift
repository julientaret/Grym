//
//  HomeView.swift
//  Grym
//
//  Écran d'accueil (onglet Wikis) — dashboard : en-tête, wikis épinglés,
//  activité récente (5 entrées) et bilan de la collection.
//  La liste complète des jeux vit dans « Mes jeux ».
//

import SwiftData
import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @StateObject private var statsViewModel = StatsViewModel()
    @State private var showingGameSearch = false
    @State private var showingGlobalSearch = false
    @State private var showingStats = false
    @State private var showingPremium = false
    /// Destination poussée depuis une entrée d'activité récente.
    @State private var activityTarget: ActivityTarget?
    @EnvironmentObject private var localization: LocalizationManager
    @EnvironmentObject private var premium: PremiumManager
    @Environment(\.theme) private var theme
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: Theme.Spacing.large) {
                    HomeHeaderView(
                        onAddGame: { showingGameSearch = true },
                        onSearch: { showingGlobalSearch = true }
                    )

                    if !viewModel.pinnedWikis.isEmpty {
                        PinnedWikisSection(
                            wikis: viewModel.pinnedWikis,
                            totalCount: viewModel.pinnedCount
                        )
                    }

                    if !viewModel.recentActivity.isEmpty {
                        RecentActivitySection(
                            entries: viewModel.recentActivity,
                            onSelect: { entry in
                                activityTarget = viewModel.target(for: entry, context: modelContext)
                            }
                        )
                    }

                    if !statsViewModel.stats.isEmpty {
                        HomeStatsSection(
                            stats: statsViewModel.stats,
                            isDetailUnlocked: premium.isPremium,
                            onOpenDetail: openStatsDetail
                        )
                    }

                    if viewModel.isDashboardEmpty {
                        dashboardEmptyState
                    }
                }
                .padding(.bottom, Theme.Spacing.xLarge)
            }
            .ignoresSafeArea(edges: .top)
            .background(background)
            .navigationDestination(for: Wiki.self) { wiki in
                WikiDetailView(wiki: wiki)
            }
            .navigationDestination(item: $activityTarget) { target in
                WikiDetailView(wiki: target.wiki, initialPage: target.page)
            }
            .navigationDestination(isPresented: $showingStats) { StatsView() }
        }
        .onAppear { reload() }
        .sheet(isPresented: $showingGameSearch, onDismiss: reload) {
            GameSearchView { _ in showingGameSearch = false }
        }
        .sheet(isPresented: $showingGlobalSearch) {
            GlobalSearchView()
        }
        .sheet(isPresented: $showingPremium) { PremiumUpgradeView() }
    }

    // MARK: Actions

    private func reload() {
        viewModel.load(context: modelContext, localization: localization)
        statsViewModel.load(context: modelContext, localization: localization)
    }

    /// Le bilan détaillé reste un avantage premium ; le résumé, lui, est visible
    /// de tous (cf. `PremiumUpgradeView`).
    private func openStatsDetail() {
        if premium.isPremium {
            showingStats = true
        } else {
            showingPremium = true
        }
    }

    // MARK: État vide

    /// Deux situations distinctes : aucun jeu du tout (onboarding + ajout),
    /// ou des jeux mais rien à mettre en avant (explication de l'épinglage).
    @ViewBuilder
    private var dashboardEmptyState: some View {
        if viewModel.totalWikiCount == 0 {
            EmptyStateView(
                systemImage: "sparkles",
                title: localization.string(.homeOnboardingTitle),
                message: localization.string(.homeOnboardingMessage),
                steps: [
                    EmptyStateStep(
                        systemImage: "magnifyingglass",
                        text: localization.string(.homeOnboardingStepSearch)
                    ),
                    EmptyStateStep(
                        systemImage: "doc.text",
                        text: localization.string(.homeOnboardingStepWiki)
                    ),
                    EmptyStateStep(
                        systemImage: "star.fill",
                        text: localization.string(.homeOnboardingStepScore)
                    )
                ]
            ) {
                WideAddGameButton { showingGameSearch = true }
            }
        } else {
            EmptyStateView(
                systemImage: "pin",
                title: localization.string(.homeNoPinnedTitle),
                message: localization.string(.homeNoPinnedMessage),
                steps: [
                    EmptyStateStep(
                        systemImage: "pin.fill",
                        text: localization.string(.homeNoPinnedStepPin)
                    ),
                    EmptyStateStep(
                        systemImage: "clock.arrow.circlepath",
                        text: localization.string(.homeNoPinnedStepActivity)
                    )
                ]
            )
        }
    }

    // MARK: Fond

    private var background: some View {
        ZStack {
            LinearGradient(
                colors: [theme.backgroundDeep, theme.background],
                startPoint: .top,
                endPoint: .bottom
            )
            RadialGradient(
                colors: [theme.glow.opacity(0.55), .clear],
                center: UnitPoint(x: 0.5, y: 0.0),
                startRadius: 4,
                endRadius: 360
            )
        }
        .ignoresSafeArea()
    }
}

#Preview {
    HomeView()
        .modelContainer(PreviewSampleData.container)
        .environmentObject(LocalizationManager())
        .environmentObject(ThemeManager())
        .environment(\.theme, GrymBlueTheme())
}
