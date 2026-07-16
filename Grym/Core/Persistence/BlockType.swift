//
//  BlockType.swift
//  Grym
//
//  Type d'un bloc de contenu dans une page de wiki.
//

import Foundation

nonisolated enum BlockType: String, Codable, CaseIterable {
    case text
    case photo
    case checklist
    case map

    /// Symbole SF représentant le type de bloc.
    var systemImage: String {
        switch self {
        case .text:      "text.alignleft"
        case .photo:     "photo"
        case .checklist: "checklist"
        case .map:       "map"
        }
    }
}
