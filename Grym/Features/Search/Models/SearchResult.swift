//
//  SearchResult.swift
//  Grym
//
//  Modèle de présentation d'un résultat de recherche globale.
//

import SwiftData
import SwiftUI

/// Nature d'un résultat (détermine icône, libellé de section et destination).
enum SearchResultKind: Int, CaseIterable, Identifiable {
    case game
    case page
    case text
    case checklistItem
    case mapPin

    var id: Int { rawValue }

    /// Clé de traduction du titre de section.
    var sectionKey: TranslationKey {
        switch self {
        case .game:          .searchSectionGames
        case .page:          .searchSectionPages
        case .text:          .searchSectionNotes
        case .checklistItem: .searchSectionChecklists
        case .mapPin:        .searchSectionPins
        }
    }

    var systemImage: String {
        switch self {
        case .game:          "gamecontroller"
        case .page:          "book.pages"
        case .text:          "note.text"
        case .checklistItem: "checklist"
        case .mapPin:        "mappin"
        }
    }
}

/// Un résultat de recherche, rattaché au wiki et éventuellement à la page
/// où le contenu a été trouvé.
struct SearchResult: Identifiable, Hashable {
    let id = UUID()
    let kind: SearchResultKind
    /// Texte principal (titre du jeu, de la page, extrait de note…).
    let title: String
    /// Contexte : « Elden Ring · Builds ».
    let subtitle: String
    let coverImageId: String?
    let coverTint: Color
    let wikiID: PersistentIdentifier
    let pageID: PersistentIdentifier?
}
