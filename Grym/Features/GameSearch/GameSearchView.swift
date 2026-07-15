//
//  GameSearchView.swift
//  Grym
//
//  Écran d'ajout de jeu : recherche live IGDB, présenté en sheet
//  depuis le bouton « + » de l'accueil.
//

import SwiftData
import SwiftUI

struct GameSearchView: View {
    /// Appelé après l'ajout d'un jeu (le wiki est déjà persisté).
    let onSelect: (IGDBGame) -> Void

    @StateObject private var viewModel = GameSearchViewModel()
    @State private var text: String = ""

    @EnvironmentObject private var localization: LocalizationManager
    @Environment(\.theme) private var theme
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        NavigationStack {
            ZStack {
                background

                VStack(spacing: Theme.Spacing.medium) {
                    searchField
                        .padding(.horizontal, Theme.Spacing.large)
                        .padding(.top, Theme.Spacing.medium)

                    content
                }
            }
            .navigationTitle(localization.string(.gameSearchTitle))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(localization.string(.commonCancel)) { dismiss() }
                }
            }
        }
    }

    // MARK: Champ de recherche

    private var searchField: some View {
        HStack(spacing: Theme.Spacing.small) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(theme.secondaryText)

            TextField(localization.string(.gameSearchPlaceholder), text: $text)
                .foregroundStyle(theme.primaryText)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .submitLabel(.search)
                .onChange(of: text) { _, newValue in
                    viewModel.queryChanged(newValue)
                }

            if !text.isEmpty {
                Button {
                    text = ""
                    viewModel.queryChanged("")
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(theme.secondaryText)
                }
            }
        }
        .padding(.horizontal, Theme.Spacing.medium)
        .padding(.vertical, Theme.Spacing.small + 2)
        .background(
            RoundedRectangle(cornerRadius: Theme.Radius.medium, style: .continuous)
                .fill(theme.surface.opacity(0.6))
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.Radius.medium, style: .continuous)
                        .stroke(.white.opacity(0.06), lineWidth: 1)
                )
        )
    }

    // MARK: Contenu selon l'état

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle:
            placeholder(icon: "gamecontroller", message: localization.string(.gameSearchPrompt))

        case .loading:
            Spacer()
            ProgressView().tint(theme.accent)
            Spacer()

        case .results(let games):
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 0) {
                    ForEach(games) { game in
                        Button {
                            addGame(game)
                        } label: {
                            GameSearchResultRow(game: game)
                        }
                        .buttonStyle(.plain)
                        Divider().overlay(theme.secondaryText.opacity(0.12))
                    }
                }
                .padding(.horizontal, Theme.Spacing.large)
            }

        case .empty:
            placeholder(icon: "magnifyingglass", message: localization.string(.gameSearchEmpty))

        case .error:
            VStack(spacing: Theme.Spacing.medium) {
                Spacer()
                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: Theme.FontSize.largeTitle))
                    .foregroundStyle(theme.secondaryText)
                Text(localization.string(.gameSearchError))
                    .font(.system(size: Theme.FontSize.body))
                    .foregroundStyle(theme.secondaryText)
                Button(localization.string(.commonRetry)) { viewModel.retry() }
                    .foregroundStyle(theme.accent)
                Spacer()
            }
        }
    }

    // MARK: Ajout

    /// Persiste le wiki du jeu choisi puis referme la recherche.
    private func addGame(_ game: IGDBGame) {
        do {
            try WikiRepository(context: modelContext).addWiki(for: game)
            // Télécharge la jaquette pour un accès offline (jeu ajouté en ligne).
            if let imageId = game.cover?.imageId {
                Task { await CoverStore.downloadIfNeeded(imageId: imageId) }
            }
            onSelect(game)
            dismiss()
        } catch {
            // La création échoue silencieusement pour l'instant ;
            // un retour d'erreur UI sera ajouté avec la gestion premium.
        }
    }

    private func placeholder(icon: String, message: String) -> some View {
        VStack(spacing: Theme.Spacing.medium) {
            Spacer()
            Image(systemName: icon)
                .font(.system(size: Theme.FontSize.largeTitle))
                .foregroundStyle(theme.secondaryText.opacity(0.7))
            Text(message)
                .font(.system(size: Theme.FontSize.body))
                .foregroundStyle(theme.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Theme.Spacing.xLarge)
            Spacer()
        }
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
    GameSearchView(onSelect: { _ in })
        .modelContainer(PreviewSampleData.container)
        .environmentObject(LocalizationManager())
        .environment(\.theme, GrymBlueTheme())
}
