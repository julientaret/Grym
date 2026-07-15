//
//  HomeView.swift
//  Grym
//
//  Écran d'accueil (onglet Wikis) : en-tête, recherche, wikis épinglés,
//  activité récente et liste de tous les wikis.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var showingGameSearch = false
    @Environment(\.theme) private var theme

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: Theme.Spacing.large) {
                HomeHeaderView(onAdd: { showingGameSearch = true })
                    .padding(.horizontal, Theme.Spacing.large)

                HomeSearchBar(text: $viewModel.searchText)
                    .padding(.horizontal, Theme.Spacing.large)

                if viewModel.searchText.isEmpty {
                    PinnedWikisSection(
                        wikis: viewModel.pinned,
                        totalCount: viewModel.pinnedCount
                    )

                    RecentActivitySection(entries: viewModel.recentActivity)
                }

                AllWikisSection(wikis: viewModel.filteredWikis)
            }
            .padding(.top, Theme.Spacing.small)
            .padding(.bottom, Theme.Spacing.xLarge)
        }
        .background(background)
        .sheet(isPresented: $showingGameSearch) {
            GameSearchView { _ in
                // TODO: créer le wiki (SwiftData) puis ouvrir l'éditeur.
                showingGameSearch = false
            }
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
        .environmentObject(LocalizationManager())
        .environmentObject(ThemeManager())
        .environment(\.theme, GrymBlueTheme())
}
