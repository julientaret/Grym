//
//  BlockContent.swift
//  Grym
//
//  Encodage du contenu des blocs. Le champ `Block.content` stocke :
//  - `.text` : le texte brut (Markdown) directement ;
//  - `.checklist` : un JSON `ChecklistContent`.
//

import Foundation

// MARK: - Checklist

nonisolated struct ChecklistItem: Codable, Identifiable, Hashable {
    var id: UUID = UUID()
    var text: String = ""
    var done: Bool = false
}

nonisolated struct ChecklistContent: Codable, Hashable {
    var title: String = ""
    var items: [ChecklistItem] = []

    var doneCount: Int { items.filter(\.done).count }
}

// MARK: - Photo

nonisolated struct PhotoContent: Codable, Hashable {
    /// Noms de fichiers locaux (cf. `ImageStore`).
    var fileNames: [String] = []
}

// MARK: - Carte annotée

nonisolated struct MapPin: Codable, Identifiable, Hashable {
    var id: UUID = UUID()
    /// Coordonnées relatives (0–1) sur l'image, indépendantes de l'affichage.
    var x: Double
    var y: Double
    var label: String = ""
}

nonisolated struct MapContent: Codable, Hashable {
    /// Nom de fichier local de l'image de carte (cf. `ImageStore`).
    var imageFileName: String?
    var pins: [MapPin] = []
}

// MARK: - Accès depuis Block

extension Block {
    /// Contenu checklist décodé/encodé depuis `content` (JSON).
    var checklist: ChecklistContent {
        get {
            (try? JSONDecoder().decode(ChecklistContent.self, from: Data(content.utf8)))
                ?? ChecklistContent()
        }
        set {
            content = (try? JSONEncoder().encode(newValue))
                .flatMap { String(data: $0, encoding: .utf8) } ?? content
        }
    }

    /// Contenu photo décodé/encodé depuis `content` (JSON).
    var photos: PhotoContent {
        get {
            (try? JSONDecoder().decode(PhotoContent.self, from: Data(content.utf8)))
                ?? PhotoContent()
        }
        set {
            content = (try? JSONEncoder().encode(newValue))
                .flatMap { String(data: $0, encoding: .utf8) } ?? content
        }
    }

    /// Contenu carte décodé/encodé depuis `content` (JSON).
    var map: MapContent {
        get {
            (try? JSONDecoder().decode(MapContent.self, from: Data(content.utf8)))
                ?? MapContent()
        }
        set {
            content = (try? JSONEncoder().encode(newValue))
                .flatMap { String(data: $0, encoding: .utf8) } ?? content
        }
    }
}
