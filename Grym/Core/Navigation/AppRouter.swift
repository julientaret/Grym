//
//  AppRouter.swift
//  Grym
//
//  Routage applicatif transverse : onglet actif et destination demandée
//  depuis l'extérieur (résultat Spotlight). `MyGamesView` consomme la
//  cible en attente et la pousse dans sa pile de navigation.
//

import Combine
import SwiftUI

/// Onglets de la navigation principale.
enum RootTab: Int {
    case home
    case myGames
    case profile
}

@MainActor
final class AppRouter: ObservableObject {
    @Published var selectedTab: RootTab = .home
    /// Wiki (et éventuelle page) à ouvrir dès que « Mes jeux » est affiché.
    @Published var pendingTarget: ActivityTarget?

    /// Bascule sur « Mes jeux » et y demande l'ouverture de la cible.
    func open(_ target: ActivityTarget) {
        selectedTab = .myGames
        pendingTarget = target
    }
}
