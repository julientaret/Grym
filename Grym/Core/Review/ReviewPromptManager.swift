//
//  ReviewPromptManager.swift
//  Grym
//
//  Décide quand proposer de noter l'app : une seule fois, au lancement qui
//  suit le passage du palier de jeux ajoutés. Drapeau scalaire → UserDefaults.
//

import Combine
import SwiftUI

@MainActor
final class ReviewPromptManager: ObservableObject {

    /// Nombre de jeux à partir duquel la demande de note est proposée.
    static let gameThreshold = 4

    /// Vrai quand la modale doit être présentée.
    @Published var isPresenting = false

    private let shownKey = "reviewPromptShown"

    /// La demande a déjà été proposée : on ne la repropose jamais.
    private var hasBeenShown: Bool {
        didSet { UserDefaults.standard.set(hasBeenShown, forKey: shownKey) }
    }

    init() {
        hasBeenShown = UserDefaults.standard.bool(forKey: shownKey)
    }

    /// Au lancement : la modale s'ouvre si la collection a atteint le palier
    /// et que la demande n'a jamais été faite. Marquée consommée dès l'affichage,
    /// quelle que soit la réponse de l'utilisateur.
    func evaluateAtLaunch(gameCount: Int) {
        guard !hasBeenShown, gameCount >= Self.gameThreshold else { return }
        hasBeenShown = true
        isPresenting = true
    }
}
