//
//  GameSortOption.swift
//  Grym
//
//  Critère de tri de la liste « Mes jeux ». Préférence simple persistée
//  dans les UserDefaults (valeur scalaire).
//

import Foundation

enum GameSortOption: String, CaseIterable, Identifiable {
    /// Date de modification décroissante (comportement historique).
    case recent
    case title
    case score
    case releaseYear
    /// Temps de jeu cumulé décroissant (sessions consignées).
    case playtime

    var id: String { rawValue }

    /// Clé de traduction du nom affiché.
    var nameKey: TranslationKey {
        switch self {
        case .recent:      .sortRecent
        case .title:       .sortTitle
        case .score:       .sortScore
        case .releaseYear: .sortReleaseYear
        case .playtime:    .sortPlaytime
        }
    }

    /// Icône SF Symbols représentant le critère.
    var systemImage: String {
        switch self {
        case .recent:      "clock"
        case .title:       "textformat.abc"
        case .score:       "star"
        case .releaseYear: "calendar"
        case .playtime:    "hourglass"
        }
    }
}
