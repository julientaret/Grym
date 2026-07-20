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
    @State private var path: [Wiki] = []
    /// Wiki créé depuis la recherche, poussé une fois la sheet refermée.
    @State private var pendingWiki: Wiki?

    @EnvironmentObject private var localization: LocalizationManager
    @EnvironmentObject private var premium: PremiumManager
    @Environment(\.theme) private var theme
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        NavigationStack(path: $path) {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: Theme.Spacing.large) {
                    header

                    if viewModel.wikis.isEmpty {
                        emptyState
                    } else {
                        LazyVStack(spacing: Theme.Spacing.small) {
                            ForEach(viewModel.wikis) { wiki in
                                if let summary = WikiSummary(wiki: wiki) {
                                    NavigationLink(value: wiki) {
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
                .padding(.top, Theme.Spacing.small)
                .padding(.bottom, Theme.Spacing.xLarge)
            }
            .background(background)
            .navigationDestination(for: Wiki.self) { wiki in
                WikiDetailView(wiki: wiki)
            }
        }
        .onAppear { viewModel.load(context: modelContext) }
        .sheet(isPresented: $showingGameSearch, onDismiss: {
            viewModel.load(context: modelContext)
            if let wiki = pendingWiki {
                pendingWiki = nil
                path.append(wiki)
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
        HStack(spacing: Theme.Spacing.xSmall + 2) {
            Text(localization.string(.myGamesTitle))
                .font(.system(size: Theme.FontSize.largeTitle, weight: .bold))
                .foregroundStyle(theme.primaryText)
            if !viewModel.wikis.isEmpty {
                Text(countLabel)
                    .font(.system(size: Theme.FontSize.title, weight: .semibold))
                    .foregroundStyle(theme.secondaryText)
            }
            Spacer()
            CircularAddGameButton { showingGameSearch = true }
        }
        .padding(.horizontal, Theme.Spacing.large)
    }

    /// « · N » en premium, « · N / 10 » au palier gratuit.
    private var countLabel: String {
        premium.isPremium
            ? "· \(viewModel.wikis.count)"
            : "· \(viewModel.wikis.count) / \(PremiumManager.freeGameLimit)"
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
        .environment(\.theme, GrymBlueTheme())
}
