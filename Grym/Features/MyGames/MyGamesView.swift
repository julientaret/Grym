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

    @EnvironmentObject private var localization: LocalizationManager
    @Environment(\.theme) private var theme
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: Theme.Spacing.large) {
                header

                if viewModel.games.isEmpty {
                    emptyState
                } else {
                    LazyVStack(spacing: Theme.Spacing.small) {
                        ForEach(viewModel.games) { game in
                            WikiRowView(wiki: game)
                                .contextMenu {
                                    Button(role: .destructive) {
                                        viewModel.delete(game, context: modelContext)
                                    } label: {
                                        Label(localization.string(.commonDelete),
                                              systemImage: "trash")
                                    }
                                }
                        }
                    }
                    .padding(.horizontal, Theme.Spacing.large)
                }
            }
            .padding(.top, Theme.Spacing.small)
            .padding(.bottom, Theme.Spacing.xLarge)
        }
        .background(background)
        .onAppear { viewModel.load(context: modelContext) }
    }

    // MARK: En-tête

    private var header: some View {
        HStack(spacing: Theme.Spacing.xSmall + 2) {
            Text(localization.string(.myGamesTitle))
                .font(.system(size: Theme.FontSize.largeTitle, weight: .bold))
                .foregroundStyle(theme.primaryText)
            if !viewModel.games.isEmpty {
                Text("· \(viewModel.games.count)")
                    .font(.system(size: Theme.FontSize.title, weight: .semibold))
                    .foregroundStyle(theme.secondaryText)
            }
            Spacer()
        }
        .padding(.horizontal, Theme.Spacing.large)
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
        .environment(\.theme, GrymBlueTheme())
}
