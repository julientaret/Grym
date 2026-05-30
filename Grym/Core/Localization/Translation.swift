//
//  Translation.swift
//  Grym
//
//  Catalogue des traductions de l'app (FR/EN).
//  Chaque texte affiché passe par une clé `TranslationKey`.
//

import Foundation

/// Langues supportées par l'application.
enum AppLanguage: String, CaseIterable {
    case french = "fr"
    case english = "en"

    /// Langue déduite des préférences système, anglais par défaut.
    nonisolated static var system: AppLanguage {
        let code = Locale.preferredLanguages.first?.prefix(2).lowercased() ?? "en"
        return AppLanguage(rawValue: String(code)) ?? .english
    }

    /// Nom natif de la langue (autonyme), ex. « Français », « English ».
    var displayName: String {
        let locale = Locale(identifier: rawValue)
        return locale.localizedString(forLanguageCode: rawValue)?.capitalized
            ?? rawValue.uppercased()
    }
}

/// Clés de traduction. Aucune string en dur dans les vues.
enum TranslationKey: String {
    case tabNotes
    case tabSearch
    case tabProfile
    case profileThemeLabel
    case profileLanguageLabel
    case themeGrymBlue
    case themeGrymViolet
}

/// Accès statique aux traductions.
enum Translation {

    static func value(for key: TranslationKey, language: AppLanguage) -> String {
        translations[language]?[key]
            ?? translations[.english]?[key]
            ?? key.rawValue
    }

    private static let translations: [AppLanguage: [TranslationKey: String]] = [
        .french: [
            .tabNotes: "Notes",
            .tabSearch: "Rechercher",
            .tabProfile: "Profil",
            .profileThemeLabel: "Thème",
            .profileLanguageLabel: "Langue",
            .themeGrymBlue: "Bleu",
            .themeGrymViolet: "Violet"
        ],
        .english: [
            .tabNotes: "Notes",
            .tabSearch: "Search",
            .tabProfile: "Profile",
            .profileThemeLabel: "Theme",
            .profileLanguageLabel: "Language",
            .themeGrymBlue: "Blue",
            .themeGrymViolet: "Violet"
        ]
    ]
}
