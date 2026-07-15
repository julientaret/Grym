//
//  HomeView.swift
//  Grym
//
//  Écran d'accueil (onglet Wikis) — dashboard : en-tête, wikis épinglés
//  et activité récente. La liste complète des jeux vit dans « Mes jeux ».
//

import SwiftData
import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var showingGameSearch = false
    @EnvironmentObject private var localization: LocalizationManager
    @Environment(\.theme) private var theme
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: Theme.Spacing.large) {
                HomeHeaderView(onAdd: { showingGameSearch = true })
                    .padding(.horizontal, Theme.Spacing.large)

                if !viewModel.pinned.isEmpty {
                    PinnedWikisSection(
                        wikis: viewModel.pinned,
                        totalCount: viewModel.pinnedCount
                    )
                }

                if !viewModel.recentActivity.isEmpty {
                    RecentActivitySection(entries: viewModel.recentActivity)
                }

                if viewModel.isDashboardEmpty {
                    dashboardEmptyState
                }
            }
            .padding(.top, Theme.Spacing.small)
            .padding(.bottom, Theme.Spacing.xLarge)
        }
        .background(background)
        .onAppear { viewModel.load(context: modelContext) }
        .sheet(isPresented: $showingGameSearch, onDismiss: {
            viewModel.load(context: modelContext)
        }) {
            GameSearchView { _ in showingGameSearch = false }
        }
    }

    // MARK: État vide

    private var dashboardEmptyState: some View {
        VStack(spacing: Theme.Spacing.medium) {
            Image(systemName: "pin")
                .font(.system(size: Theme.FontSize.largeTitle))
                .foregroundStyle(theme.secondaryText.opacity(0.7))
            Text(localization.string(.homeDashboardEmpty))
                .font(.system(size: Theme.FontSize.body))
                .foregroundStyle(theme.secondaryText)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, Theme.Spacing.large)
        .padding(.top, Theme.Spacing.xLarge)
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
