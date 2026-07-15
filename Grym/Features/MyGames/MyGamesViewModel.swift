//
//  MyGamesViewModel.swift
//  Grym
//
//  Logique de l'onglet « Mes jeux » : liste de tous les wikis ajoutés,
//  triés par date de modification, avec suppression.
//

import Combine
import SwiftData
import SwiftUI

@MainActor
final class MyGamesViewModel: ObservableObject {

    /// Résumés affichés dans la liste.
    @Published private(set) var games: [WikiSummary] = []

    /// Wikis persistés correspondants (source pour la suppression).
    private var wikis: [Wiki] = []

    /// Recharge la liste depuis le contexte.
    func load(context: ModelContext) {
        let descriptor = FetchDescriptor<Wiki>(
            sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
        )
        do {
            wikis = try context.fetch(descriptor)
            games = wikis.compactMap(WikiSummary.init(wiki:))
        } catch {
            wikis = []
            games = []
        }
    }

    /// Supprime le wiki correspondant à un résumé, puis recharge.
    func delete(_ summary: WikiSummary, context: ModelContext) {
        guard let wiki = wikis.first(where: { wiki in
            wiki.game.map { "\($0.igdbId)" } == summary.id
        }) else { return }

        try? WikiRepository(context: context).delete(wiki)
        load(context: context)
    }
}
