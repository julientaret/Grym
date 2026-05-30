//
//  LocalizationManager.swift
//  Grym
//
//  Gère la langue active et l'accès aux traductions.
//  Injecté dans l'environnement SwiftUI.
//

import Combine
import SwiftUI

@MainActor
final class LocalizationManager: ObservableObject {

    static let shared = LocalizationManager()

    @Published private(set) var language: AppLanguage

    private let storageKey = "selectedLanguage"

    init() {
        let saved = UserDefaults.standard.string(forKey: storageKey)
            .flatMap(AppLanguage.init(rawValue:))
        language = saved ?? .system
    }

    /// Retourne la traduction associée à une clé pour la langue active.
    func string(_ key: TranslationKey) -> String {
        Translation.value(for: key, language: language)
    }

    /// Bascule sur la langue demandée et persiste le choix (préférence scalaire).
    func select(_ language: AppLanguage) {
        guard language != self.language else { return }
        self.language = language
        UserDefaults.standard.set(language.rawValue, forKey: storageKey)
    }
}
