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
    /// Nom donné au bloc par l'utilisateur. Vide = le nom du type sert
    /// de repli à l'affichage. Valeur par défaut pour la migration légère
    /// des blocs créés avant l'introduction du champ.
    var title: String = ""
    /// Contenu du bloc, encodé en JSON selon le type.
    var content: String
    var order: Int

    init(type: BlockType, title: String = "", content: String, order: Int) {
        self.typeRaw = type.rawValue
        self.title = title
        self.content = content
        self.order = order
    }

    /// Type du bloc (repli sur `.text` si valeur inconnue).
    var type: BlockType {
        get { BlockType(rawValue: typeRaw) ?? .text }
        set { typeRaw = newValue.rawValue }
    }
}
