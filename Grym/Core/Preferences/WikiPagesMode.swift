//
//  WikiPagesMode.swift
//  Grym
//
//  Mode d'affichage des pages d'un wiki. Préférence globale, réglée
//  depuis le profil et appliquée à tous les wikis.
//

import Foundation

enum WikiPagesMode: String, CaseIterable, Identifiable {
    case list, tabs, cards

    var id: String { rawValue }

    /// Clé de traduction du nom affiché.
    var nameKey: TranslationKey {
        switch self {
        case .list:  .wikiModeList
        case .tabs:  .wikiModeTabs
        case .cards: .wikiModeCards
        }
    }

    /// Icône SF Symbols représentant le mode.
    var systemImage: String {
        switch self {
        case .list:  "list.bullet"
        case .tabs:  "rectangle.topthird.inset.filled"
        case .cards: "square.grid.2x2"
        }
    }
}
