//
//  GameSearchViewModel.swift
//  Grym
//
//  Recherche live de jeux via IGDB : debounce, états de chargement,
//  résultats, vide et erreur. Alimente l'écran d'ajout de jeu.
//

import Combine
import SwiftUI

@MainActor
final class GameSearchViewModel: ObservableObject {

    /// État courant de la recherche.
    enum State: Equatable {
        case idle
        case loading
        case results([IGDBGame])
        case empty
        case error
    }

    @Published var query: String = ""
    @Published private(set) var state: State = .idle

    private let service: IGDBServiceProtocol
    private var searchTask: Task<Void, Never>?

    /// Nombre minimum de caractères avant de lancer une requête.
    private let minQueryLength = 2
    /// Délai de debounce (ms) entre la frappe et la requête réseau.
    private let debounceMilliseconds: UInt64 = 350

    init(service: IGDBServiceProtocol? = nil) {
        // `IGDBService.shared` est isolé au MainActor (isolation module par défaut) ;
        // l'init du ViewModel étant MainActor, l'accès est ici valide.
        self.service = service ?? IGDBService.shared
    }

    /// À appeler à chaque changement du texte : debounce puis recherche.
    func queryChanged(_ text: String) {
        query = text
        searchTask?.cancel()

        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count >= minQueryLength else {
            state = .idle
            return
        }

        searchTask = Task { [weak self] in
            guard let self else { return }
            try? await Task.sleep(nanoseconds: self.debounceMilliseconds * 1_000_000)
            guard !Task.isCancelled else { return }
            await self.performSearch(trimmed)
        }
    }

    /// Relance la dernière recherche (bouton « Réessayer »).
    func retry() {
        queryChanged(query)
    }

    // MARK: - Requête

    private func performSearch(_ query: String) async {
        state = .loading
        do {
            let games = try await service.searchGames(matching: query)
            guard !Task.isCancelled else { return }
            state = games.isEmpty ? .empty : .results(games)
        } catch is CancellationError {
            // Ignorée : une nouvelle frappe a annulé la requête.
        } catch {
            guard !Task.isCancelled else { return }
            state = .error
        }
    }
}
