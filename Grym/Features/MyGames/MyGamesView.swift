//
//  MyGamesView.swift
//  Grym
//
//  Onglet « Mes jeux » : liste complète des jeux ajoutés (wikis),
//  avec suppression par menu contextuel.
//

import SwiftData
import SwiftUI

struct MyGamesView: View {
    @StateObject private var viewModel = MyGamesViewModel()
    @State private var showingGameSearch = false
    @State private var path: [ActivityTarget] = []
    /// Wiki créé depuis la recherche, poussé une fois la sheet refermée.
    @State private var pendingWiki: Wiki?

    @EnvironmentObject private var localization: LocalizationManager
    @EnvironmentObject private var premium: PremiumManager
    @EnvironmentObject private var router: AppRouter
    @Environment(\.theme) private var theme
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        NavigationStack(path: $path) {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: Theme.Spacing.large) {
                    header

                    if viewModel.hasNoGame {
                        emptyState
                    } else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: Theme.Spacing.small) {
                                GameSortMenu(selection: $viewModel.sortOption)
                                GameStatusFilterMenu(selection: $viewModel.statusFilter)
                            }
                            .padding(.horizontal, Theme.Spacing.large)
                        }

                        if viewModel.wikis.isEmpty {
                            Text(localization.string(.myGamesFilterEmpty))
                                .font(.system(size: Theme.FontSize.caption))
                                .foregroundStyle(theme.secondaryText)
                                .padding(.horizontal, Theme.Spacing.large)
                        }

                        LazyVStack(spacing: Theme.Spacing.small) {
                            ForEach(viewModel.wikis) { wiki in
                                if let summary = WikiSummary(wiki: wiki) {
                                    NavigationLink(value: ActivityTarget(wiki: wiki, page: nil)) {
                                        WikiRowView(wiki: summary)
                                    }
                                    .buttonStyle(.plain)
                                    .contextMenu {
                                        Button(role: .destructive) {
                                            viewModel.delete(wiki, context: modelContext)
                                        } label: {
                                            Label(localization.string(.commonDelete),
                                                  systemImage: "trash")
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, Theme.Spacing.large)

                        // Le bouton d'ajout est déjà porté par l'état vide.
                        WideAddGameButton { showingGameSearch = true }
                            .padding(.horizontal, Theme.Spacing.large)
                            .padding(.top, Theme.Spacing.small)
                    }
                }
                .padding(.bottom, Theme.Spacing.xLarge)
            }
            .ignoresSafeArea(edges: .top)
            .background(background)
            .navigationDestination(for: ActivityTarget.self) { target in
                WikiDetailView(wiki: target.wiki, initialPage: target.page)
            }
        }
        .onAppear { viewModel.load(context: modelContext) }
        // Cible venue de Spotlight : poussée dès que l'onglet est affiché.
        .onChange(of: router.pendingTarget) { _, target in
            guard let target else { return }
            router.pendingTarget = nil
            path.append(target)
        }
        .sheet(isPresented: $showingGameSearch, onDismiss: {
            viewModel.load(context: modelContext)
            if let wiki = pendingWiki {
                pendingWiki = nil
                path.append(ActivityTarget(wiki: wiki, page: nil))
            }
        }) {
            GameSearchView { wiki in
                pendingWiki = wiki
                showingGameSearch = false
            }
        }
    }

    // MARK: En-tête

    private var header: some View {
        BannerHeaderView(
            imageName: "banner-my-games",
            height: Theme.Size.bannerHeightCompact
        ) {
            HStack(spacing: Theme.Spacing.xSmall + 2) {
                Text(localization.string(.myGamesTitle))
                    .font(.system(size: Theme.FontSize.largeTitle, weight: .bold))
                    .foregroundStyle(theme.primaryText)
                if !viewModel.hasNoGame {
                    Text(countLabel)
                        .font(.system(size: Theme.FontSize.title, weight: .semibold))
                        .foregroundStyle(theme.secondaryText)
                }
                Spacer()
                CircularAddGameButton { showingGameSearch = true }
            }
        }
    }

    /// « · N » en premium, « · N / 10 » au palier gratuit.
    /// Compte toujours la collection entière, indépendamment du filtre.
    private var countLabel: String {
        premium.isPremium
            ? "· \(viewModel.allWikis.count)"
            : "· \(viewModel.allWikis.count) / \(PremiumManager.freeGameLimit)"
    }

    // MARK: État vide

    private var emptyState: some View {
        EmptyStateView(
            systemImage: "gamecontroller",
            title: localization.string(.myGamesEmptyTitle),
            message: localization.string(.myGamesEmptyMessage),
            steps: emptyStateSteps
        ) {
            WideAddGameButton { showingGameSearch = true }
        }
    }

    /// La mention du palier gratuit n'a de sens que hors premium.
    private var emptyStateSteps: [EmptyStateStep] {
        var steps = [
            EmptyStateStep(
                systemImage: "magnifyingglass",
                text: localization.string(.myGamesEmptyStepSearch)
            )
        ]
        if !premium.isPremium {
            steps.append(
                EmptyStateStep(
                    systemImage: "sparkles",
                    text: localization.string(.myGamesEmptyStepLimit)
                )
            )
        }
        return steps
    }

    // MARK: Fond

    private var background: some View {
        LinearGradient(
            colors: [theme.backgroundDeep, theme.background],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}

#Preview {
    MyGamesView()
        .modelContainer(PreviewSampleData.container)
        .environmentObject(LocalizationManager())
        .environmentObject(PremiumManager())
        .environmentObject(AppRouter())
        .environment(\.theme, GrymBlueTheme())
}
