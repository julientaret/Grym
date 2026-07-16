//
//  WikiMediaViewModel.swift
//  Grym
//
//  Récupère les médias IGDB (captures, illustrations) d'un jeu et les persiste
//  sur le `Game`. Appelé à l'ouverture du détail d'un wiki : couvre aussi les
//  jeux ajoutés avant l'arrivée de la feature, dont les médias sont vides.
//

import Combine
import SwiftData
import SwiftUI

@MainActor
final class WikiMediaViewModel: ObservableObject {

    private let service: IGDBServiceProtocol

    init(service: IGDBServiceProtocol? = nil) {
        // `IGDBService.shared` est isolé au MainActor (isolation module par défaut) ;
        // l'init du ViewModel étant MainActor, l'accès est ici valide.
        self.service = service ?? IGDBService.shared
    }

    /// Charge les médias du jeu s'ils n'ont jamais été récupérés, puis persiste.
    ///
    /// Les erreurs ne remontent pas à l'UI : les médias sont décoratifs et
    /// `mediaFetchedAt` reste `nil`, ce qui relancera l'essai à la prochaine
    /// ouverture du wiki plutôt que d'alerter l'utilisateur.
    func loadIfNeeded(for game: Game?, context: ModelContext) async {
        guard let game, game.mediaFetchedAt == nil else { return }

        guard let media = try? await service.gameMedia(id: game.igdbId) else { return }
        guard !Task.isCancelled else { return }

        game.apply(media)
        try? context.save()
    }
}
