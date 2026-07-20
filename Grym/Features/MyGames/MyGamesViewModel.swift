//
//  MyGamesViewModel.swift
//  Grym
//
//  Logique de l'onglet « Mes jeux » : liste de tous les wikis ajoutés,
//  triée selon le critère choisi, avec suppression.
//

import Combine
import SwiftData
import SwiftUI

@MainActor
final class MyGamesViewModel: ObservableObject {

    /// Clé UserDefaults du critère de tri retenu entre deux sessions.
    private static let sortStorageKey = "myGames.sortOption"

    /// Wikis persistés, dans l'ordre du tri courant.
    @Published private(set) var wikis: [Wiki] = []

    /// Critère de tri actif ; toute modification retrie la liste en place.
    @Published var sortOption: GameSortOption {
        didSet {
            guard sortOption != oldValue else { return }
            UserDefaults.standard.set(sortOption.rawValue, forKey: Self.sortStorageKey)
            wikis = sorted(wikis)
        }
    }

    init() {
        let stored = UserDefaults.standard.string(forKey: Self.sortStorageKey)
        sortOption = stored.flatMap(GameSortOption.init(rawValue:)) ?? .recent
    }

    /// Recharge la liste depuis le contexte.
    func load(context: ModelContext) {
        let descriptor = FetchDescriptor<Wiki>(
            sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
        )
        wikis = sorted((try? context.fetch(descriptor)) ?? [])
    }

    /// Supprime un wiki, puis recharge.
    func delete(_ wiki: Wiki, context: ModelContext) {
        try? WikiRepository(context: context).delete(wiki)
        load(context: context)
    }

    // MARK: Tri

    /// Applique le critère courant. Le tri se fait en mémoire : `score` et
    /// `releaseYear` dépendent de la relation `game`, hors de portée d'un
    /// `SortDescriptor` fiable côté SwiftData.
    private func sorted(_ wikis: [Wiki]) -> [Wiki] {
        switch sortOption {
        case .recent:
            wikis.sorted { $0.updatedAt > $1.updatedAt }
        case .title:
            wikis.sorted {
                let lhs = $0.game?.title ?? ""
                let rhs = $1.game?.title ?? ""
                return lhs.localizedStandardCompare(rhs) == .orderedAscending
            }
        case .score:
            wikis.sorted { $0.score > $1.score }
        case .releaseYear:
            // Les jeux sans année connue ferment la marche.
            wikis.sorted { ($0.game?.releaseYear ?? .min) > ($1.game?.releaseYear ?? .min) }
        }
    }
}
