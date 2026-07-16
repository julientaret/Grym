//
//  PremiumManager.swift
//  Grym
//
//  État de l'abonnement premium et limite du palier gratuit.
//  Persisté en UserDefaults (préférence scalaire). StoreKit pilotera
//  `isPremium` plus tard (achat + restauration).
//

import Combine
import Foundation

@MainActor
final class PremiumManager: ObservableObject {

    /// Nombre maximum de jeux distincts au palier gratuit.
    static let freeGameLimit = 10

    @Published private(set) var isPremium: Bool

    private let storageKey = "isPremium"

    init() {
        isPremium = UserDefaults.standard.bool(forKey: storageKey)
    }

    /// Met à jour le statut premium (appelé après achat/restauration StoreKit).
    func setPremium(_ value: Bool) {
        guard value != isPremium else { return }
        isPremium = value
        UserDefaults.standard.set(value, forKey: storageKey)
    }
}
