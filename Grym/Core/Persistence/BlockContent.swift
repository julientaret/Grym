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
}
