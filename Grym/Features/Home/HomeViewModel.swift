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
    /// chaque ajout).
    func load(context: ModelContext, localization: LocalizationManager) {
        let descriptor = FetchDescriptor<Wiki>(
            sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
        )
        do {
            let wikis = try context.fetch(descriptor)
            totalWikiCount = wikis.count
            pinnedWikis = wikis.filter(\.isPinned)
            pinnedCount = pinnedWikis.count
            recentActivity = Self.makeActivity(from: wikis, localization: localization)
        } catch {
            totalWikiCount = 0
            pinnedWikis = []
            pinnedCount = 0
            recentActivity = []
        }
    }

    // MARK: - Navigation

    /// Résout la cible de navigation d'une entrée d'activité : le wiki, et
    /// la page visée quand l'entrée en désigne une.
    func target(for entry: ActivityEntry, context: ModelContext) -> ActivityTarget? {
        guard let wikiID = entry.wikiID,
              let wiki = context.model(for: wikiID) as? Wiki else { return nil }
        let page = entry.pageID.flatMap { context.model(for: $0) as? Page }
        return ActivityTarget(wiki: wiki, page: page)
    }

    // MARK: - Activité récente

    /// Construit le flux d'activité : wikis (pages) créés et notes attribuées
    /// ou modifiées, fusionnés puis triés du plus récent au plus ancien.
    private static func makeActivity(
        from wikis: [Wiki],
        localization: LocalizationManager
    ) -> [ActivityEntry] {
        let entries = wikis.flatMap { wiki -> [ActivityEntry] in
            guard let game = wiki.game else { return [] }
            let tint = Color.grymTint(for: game.title)

            let created = wiki.pages.map { page in
                ActivityEntry(
                    kind: .page,
                    title: localization.string(.homeActivityNewWiki),
                    subtitle: "\(game.title) · \(page.title)",
                    coverImageId: game.coverImageId,
                    coverTint: tint,
                    date: page.createdAt,
                    wikiID: wiki.persistentModelID,
                    pageID: page.persistentModelID
                )
            }

            // Une seule entrée par jeu : le dernier changement de note connu.
            let scored = wiki.scoreUpdatedAt.map { date in
                [ActivityEntry(
                    kind: .note,
                    title: localization.string(.homeActivityScore),
                    subtitle: "\(game.title) · \(wiki.score)/100",
                    coverImageId: game.coverImageId,
                    coverTint: tint,
                    date: date,
                    wikiID: wiki.persistentModelID
                )]
            } ?? []

            // Une entrée par session consignée.
            let played = wiki.sessions.map { session in
                ActivityEntry(
                    kind: .session,
                    title: localization.string(.homeActivitySession),
                    subtitle: "\(game.title) · \(session.minutes.playtimeLabel(hourUnit: localization.string(.durationHourUnit), minuteUnit: localization.string(.durationMinuteUnit)))",
                    coverImageId: game.coverImageId,
                    coverTint: tint,
                    date: session.date,
                    wikiID: wiki.persistentModelID
                )
            }

            // Une seule entrée par jeu : le dernier changement de statut.
            let statused = wiki.statusUpdatedAt.map { date in
                [ActivityEntry(
                    kind: .status,
                    title: localization.string(.homeActivityStatus),
                    subtitle: "\(game.title) · \(localization.string(wiki.status.nameKey))",
                    coverImageId: game.coverImageId,
                    coverTint: tint,
                    date: date,
                    wikiID: wiki.persistentModelID
                )]
            } ?? []

            return created + scored + played + statused
        }

        return Array(entries.sorted { $0.date > $1.date }.prefix(activityLimit))
    }

    /// Nombre maximal d'entrées affichées dans le flux.
    private static let activityLimit = 10
}
