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

    /// Wikis persistés, triés par date de modification décroissante.
    @Published private(set) var wikis: [Wiki] = []

    /// Recharge la liste depuis le contexte.
    func load(context: ModelContext) {
        let descriptor = FetchDescriptor<Wiki>(
            sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
        )
        wikis = (try? context.fetch(descriptor)) ?? []
    }

    /// Supprime un wiki, puis recharge.
    func delete(_ wiki: Wiki, context: ModelContext) {
        try? WikiRepository(context: context).delete(wiki)
        load(context: context)
    }
}
