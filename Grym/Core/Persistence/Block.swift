//
//  Block.swift
//  Grym
//
//  Bloc de contenu d'une page (texte, photo, checklist, carte).
//  Le type est persisté en `String` (robuste aux migrations).
//

import Foundation
import SwiftData

@Model
final class Block {
    var page: Page?
    /// Type persisté ; exposé via la propriété calculée `type`.
    var typeRaw: String
    /// Contenu du bloc, encodé en JSON selon le type.
    var content: String
    var order: Int

    init(type: BlockType, content: String, order: Int) {
        self.typeRaw = type.rawValue
        self.content = content
        self.order = order
    }

    /// Type du bloc (repli sur `.text` si valeur inconnue).
    var type: BlockType {
        get { BlockType(rawValue: typeRaw) ?? .text }
        set { typeRaw = newValue.rawValue }
    }
}
