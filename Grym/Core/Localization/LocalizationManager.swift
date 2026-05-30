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

    @Published var language: AppLanguage

    init(language: AppLanguage = .system) {
        self.language = language
    }

    /// Retourne la traduction associée à une clé pour la langue active.
    func string(_ key: TranslationKey) -> String {
        Translation.value(for: key, language: language)
    }
}
