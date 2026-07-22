//
//  MyGamesViewModel.swift
//  Grym
//
//  Logique de l'onglet « Mes jeux » : liste de tous les wikis ajoutés,
//  filtrée par statut et triée selon le critère choisi, avec suppression.
//

import Combine
import SwiftData
import SwiftUI

@MainActor
final class MyGamesViewModel: ObservableObject {

    /// Clé UserDefaults du critère de tri retenu entre deux sessions.
    private static let sortStorageKey = "myGames.sortOption"
    /// Clé UserDefaults du filtre de statut retenu entre deux sessions.
    private static let statusStorageKey = "myGames.statusFilter"

    /// Tous les wikis persistés, dans l'ordre du tri courant.
    @Published private(set) var allWikis: [Wiki] = []

    /// Critère de tri actif ; toute modification retrie la liste en place.
    @Published var sortOption: GameSortOption {
        didSet {
            guard sortOption != oldValue else { return }
            UserDefaults.standard.set(sortOption.rawValue, forKey: Self.sortStorageKey)
            allWikis = sorted(allWikis)
        }
    }

    /// Statut filtré ; `nil` = tous les jeux.
    @Published var statusFilter: GameStatus? {
        didSet {
            guard statusFilter != oldValue else { return }
            UserDefaults.standard.set(statusFilter?.rawValue, forKey: Self.statusStorageKey)
        }
    }

    init() {
        let storedSort = UserDefaults.standard.string(forKey: Self.sortStorageKey)
        sortOption = storedSort.flatMap(GameSortOption.init(rawValue:)) ?? .recent
        let storedStatus = UserDefaults.standard.string(forKey: Self.statusStorageKey)
        statusFilter = storedStatus.flatMap(GameStatus.init(rawValue:))
    }

    /// Wikis affichés : filtre de statut appliqué au tri courant.
    var wikis: [Wiki] {
        guard let statusFilter else { return allWikis }
        return allWikis.filter { $0.status == statusFilter }
    }

    /// Vrai si la collection est vide (à distinguer d'un filtre sans résultat).
    var hasNoGame: Bool { allWikis.isEmpty }

    /// Recharge la liste depuis le contexte.
    func load(context: ModelContext) {
        let descriptor = FetchDescriptor<Wiki>(
            sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
        )
        allWikis = sorted((try? context.fetch(descriptor)) ?? [])
    }

    /// Supprime un wiki, puis recharge.
    func delete(_ wiki: Wiki, context: ModelContext) {
        try? WikiRepository(context: context).delete(wiki)
        load(context: context)
    }

    // MARK: Tri

    /// Applique le critère courant. Le tri se fait en mémoire : `score`,
    /// `releaseYear` et `playtime` dépendent de relations, hors de portée d'un
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
        case .playtime:
            wikis.sorted { $0.totalPlayMinutes > $1.totalPlayMinutes }
        }
    }
}
