//
//  SessionMood.swift
//  Grym
//
//  Ressenti d'une session de jeu. Persisté en `String` sur `PlaySession`.
//

import SwiftUI

enum SessionMood: String, CaseIterable, Identifiable {
    case hyped
    case good
    case neutral
    case rough

    var id: String { rawValue }

    /// Clé de traduction du libellé.
    var nameKey: TranslationKey {
        switch self {
        case .hyped:   .moodHyped
        case .good:    .moodGood
        case .neutral: .moodNeutral
        case .rough:   .moodRough
        }
    }

    /// Icône SF Symbols du ressenti.
    var systemImage: String {
        switch self {
        case .hyped:   "flame.fill"
        case .good:    "hand.thumbsup.fill"
        case .neutral: "minus.circle.fill"
        case .rough:   "cloud.bolt.fill"
        }
    }

    var color: Color {
        switch self {
        case .hyped:   .grymMoodHyped
        case .good:    .grymMoodGood
        case .neutral: .grymMoodNeutral
        case .rough:   .grymMoodRough
        }
    }
}
