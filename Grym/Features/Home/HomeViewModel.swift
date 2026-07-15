//
//  HomeViewModel.swift
//  Grym
//
//  Logique de l'écran d'accueil : expose les wikis, les épinglés et
//  l'activité récente. Données mockées en attendant la couche SwiftData.
//

import Combine
import SwiftData
import SwiftUI

@MainActor
final class HomeViewModel: ObservableObject {

    /// Wikis épinglés (défilement horizontal).
    @Published private(set) var pinned: [WikiSummary] = []
    /// Nombre total d'épinglés (peut dépasser le nombre chargé/affiché).
    @Published private(set) var pinnedCount: Int = 0
    /// Flux d'activité récente.
    @Published private(set) var recentActivity: [ActivityEntry] = []
    /// Tous les wikis, triés par date de modification décroissante.
    @Published private(set) var allWikis: [WikiSummary] = []
    /// Texte de recherche locale.
    @Published var searchText: String = ""

    /// Wikis filtrés par la recherche locale (titre).
    var filteredWikis: [WikiSummary] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return allWikis }
        return allWikis.filter { $0.title.localizedCaseInsensitiveContains(query) }
    }

    init() {}

    // MARK: - Chargement depuis SwiftData

    /// Recharge les wikis depuis le contexte (au premier affichage et après
    /// chaque ajout). L'activité récente reste vide tant qu'aucun journal
    /// d'événements n'existe.
    func load(context: ModelContext) {
        let descriptor = FetchDescriptor<Wiki>(
            sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
        )
        do {
            let wikis = try context.fetch(descriptor)
            allWikis = wikis.compactMap(WikiSummary.init(wiki:))
            let pinnedWikis = wikis.filter(\.isPinned)
            pinned = pinnedWikis.compactMap(WikiSummary.init(wiki:))
            pinnedCount = pinnedWikis.count
            recentActivity = []
        } catch {
            allWikis = []
            pinned = []
            pinnedCount = 0
            recentActivity = []
        }
    }

}
