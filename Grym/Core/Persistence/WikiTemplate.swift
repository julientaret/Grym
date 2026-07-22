//
//  WikiTemplate.swift
//  Grym
//
//  Modèles de démarrage d'un carnet : un jeu de pages pré-nommées, chacune
//  amorcée avec les blocs adaptés. Résout la page blanche à l'ajout d'un jeu.
//

import Foundation

enum WikiTemplate: String, CaseIterable, Identifiable {
    case rpg
    case soulslike
    case openWorld
    case roguelike

    var id: String { rawValue }

    /// Clé de traduction du nom du modèle.
    var nameKey: TranslationKey {
        switch self {
        case .rpg:       .templateRPG
        case .soulslike: .templateSoulslike
        case .openWorld: .templateOpenWorld
        case .roguelike: .templateRoguelike
        }
    }

    /// Clé de traduction de la description (exemples de pages créées).
    var descriptionKey: TranslationKey {
        switch self {
        case .rpg:       .templateRPGHint
        case .soulslike: .templateSoulslikeHint
        case .openWorld: .templateOpenWorldHint
        case .roguelike: .templateRoguelikeHint
        }
    }

    var systemImage: String {
        switch self {
        case .rpg:       "shield.lefthalf.filled"
        case .soulslike: "flame"
        case .openWorld: "map"
        case .roguelike: "dice"
        }
    }

    /// Pages créées par le modèle, dans l'ordre, avec leurs blocs d'amorce.
    var pages: [(titleKey: TranslationKey, blocks: [BlockType])] {
        switch self {
        case .rpg:
            [(.templatePageQuests, [.checklist]),
             (.templatePageBuilds, [.text]),
             (.templatePageItems, [.checklist]),
             (.templatePageLore, [.text])]
        case .soulslike:
            [(.templatePageBosses, [.checklist]),
             (.templatePageBuilds, [.text]),
             (.templatePageZones, [.text]),
             (.templatePageItems, [.checklist])]
        case .openWorld:
            [(.templatePageCollectibles, [.checklist]),
             (.templatePageMaps, [.map]),
             (.templatePageTodo, [.checklist]),
             (.templatePageNotes, [.text])]
        case .roguelike:
            [(.templatePageRuns, [.text]),
             (.templatePageSynergies, [.text]),
             (.templatePageCharacters, [.text]),
             (.templatePageStrategies, [.text])]
        }
    }
}
