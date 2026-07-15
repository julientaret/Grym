//
//  Page.swift
//  Grym
//
//  Page nommée d'un wiki, contenant un flux de blocs ordonnés.
//

import Foundation
import SwiftData

@Model
final class Page {
    var wiki: Wiki?
    var title: String
    var order: Int

    /// Blocs de la page (supprimés en cascade).
    @Relationship(deleteRule: .cascade, inverse: \Block.page)
    var blocks: [Block] = []

    init(title: String, order: Int) {
        self.title = title
        self.order = order
    }
}
