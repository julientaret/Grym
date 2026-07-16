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

    @EnvironmentObject private var localization: LocalizationManager
    @EnvironmentObject private var premium: PremiumManager
    @Environment(\.theme) private var theme
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        NavigationStack {
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
                    }

                    WideAddGameButton { showingGameSearch = true }
                        .padding(.horizontal, Theme.Spacing.large)
                        .padding(.top, Theme.Spacing.small)
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
        }) {
            GameSearchView { _ in showingGameSearch = false }
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
        VStack(spacing: Theme.Spacing.medium) {
            Image(systemName: "gamecontroller")
                .font(.system(size: Theme.FontSize.largeTitle))
                .foregroundStyle(theme.secondaryText.opacity(0.7))
            Text(localization.string(.homeEmptyWikis))
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
