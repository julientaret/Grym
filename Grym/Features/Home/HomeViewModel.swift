//
//  HomeViewModel.swift
//  Grym
//
//  Logique de l'écran d'accueil (dashboard) : wikis épinglés et
//  activité récente, chargés depuis SwiftData.
//

import Combine
import SwiftData
import SwiftUI

@MainActor
final class HomeViewModel: ObservableObject {

    /// Wikis épinglés (défilement horizontal, navigables vers le détail).
    @Published private(set) var pinnedWikis: [Wiki] = []
    /// Nombre total d'épinglés (peut dépasser le nombre chargé/affiché).
    @Published private(set) var pinnedCount: Int = 0
    /// Flux d'activité récente.
    @Published private(set) var recentActivity: [ActivityEntry] = []
    /// Nombre total de wikis (pour distinguer « aucun jeu » de « rien d'épinglé »).
    @Published private(set) var totalWikiCount: Int = 0

    /// Vrai quand le dashboard n'a rien à afficher (ni épinglé, ni activité).
    var isDashboardEmpty: Bool { pinnedWikis.isEmpty && recentActivity.isEmpty }

    init() {}

    // MARK: - Chargement depuis SwiftData

    /// Recharge le dashboard depuis le contexte (au premier affichage et après
    /// chaque ajout). L'activité récente reste vide tant qu'aucun journal
    /// d'événements n'existe.
    func load(context: ModelContext) {
        let descriptor = FetchDescriptor<Wiki>(
            sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
        )
        do {
            let wikis = try context.fetch(descriptor)
            totalWikiCount = wikis.count
            pinnedWikis = wikis.filter(\.isPinned)
            pinnedCount = pinnedWikis.count
            recentActivity = []
        } catch {
            totalWikiCount = 0
            pinnedWikis = []
            pinnedCount = 0
            recentActivity = []
        }
    }
}
