//
//  ThemeManager.swift
//  Grym
//
//  Détient le thème actif, le persiste et permet d'en changer à chaud.
//  Injecté dans l'environnement ; le choix survit aux relances.
//

import Combine
import SwiftUI

@MainActor
final class ThemeManager: ObservableObject {

    @Published private(set) var theme: any AppTheme

    private let storageKey = "selectedThemeID"

    init() {
        let savedID = UserDefaults.standard.string(forKey: storageKey)
            .flatMap(ThemeID.init(rawValue:)) ?? .grymBlue
        theme = savedID.makeTheme()
    }

    /// Bascule sur le thème demandé et persiste le choix (préférence scalaire).
    func select(_ id: ThemeID) {
        guard id != theme.id else { return }
        theme = id.makeTheme()
        UserDefaults.standard.set(id.rawValue, forKey: storageKey)
    }

    /// Repasse au thème gratuit si un thème premium est actif sans droit
    /// (premium expiré, restauration sur un autre appareil, etc.).
    func enforceEntitlement(isPremium: Bool) {
        guard !isPremium, theme.id.requiresPremium else { return }
        select(.free)
    }
}
