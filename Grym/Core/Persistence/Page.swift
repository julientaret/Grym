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
    /// Date de création (alimente le flux d'activité de l'accueil).
    /// Valeur par défaut requise pour la migration légère des pages existantes.
    var createdAt: Date = Date()

    /// Blocs de la page (supprimés en cascade).
    @Relationship(deleteRule: .cascade, inverse: \Block.page)
    var blocks: [Block] = []

    init(title: String, order: Int, createdAt: Date = Date()) {
        self.title = title
        self.order = order
        self.createdAt = createdAt
    }
}
