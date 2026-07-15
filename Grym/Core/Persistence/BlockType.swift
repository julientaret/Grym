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
}
