//
//  GlobalSearchViewModel.swift
//  Grym
//
//  Recherche globale hors ligne : parcourt jeux, pages, notes, checklists
//  et repères de carte du contexte SwiftData.
//

import Combine
import SwiftData
import SwiftUI

@MainActor
final class GlobalSearchViewModel: ObservableObject {

    /// Requête saisie ; toute modification relance la recherche.
    @Published var query: String = ""
    @Published private(set) var results: [SearchResult] = []

    /// Longueur d'extrait affichée autour d'une occurrence dans une note.
    private static let snippetLength = 90
    /// Plafond de résultats, pour garder l'affichage lisible.
    private static let resultLimit = 60

    /// Résultats groupés par nature, dans l'ordre des sections.
    var sections: [(kind: SearchResultKind, results: [SearchResult])] {
        SearchResultKind.allCases.compactMap { kind in
            let matching = results.filter { $0.kind == kind }
            return matching.isEmpty ? nil : (kind, matching)
        }
    }

    var hasQuery: Bool {
        !query.trimmingCharacters(in: .whitespaces).isEmpty
    }

    /// Relance la recherche sur le contexte courant.
    /// Le corpus est local et de taille modeste : parcours en mémoire.
    func search(context: ModelContext) {
        let needle = query.trimmingCharacters(in: .whitespaces)
        guard !needle.isEmpty else {
            results = []
            return
        }

        let wikis = (try? context.fetch(FetchDescriptor<Wiki>())) ?? []
        var found: [SearchResult] = []

        for wiki in wikis {
            guard let game = wiki.game else { continue }
            let tint = Color.grymTint(for: game.title)

            func result(
                _ kind: SearchResultKind,
                _ title: String,
                _ context: String,
                page: Page? = nil
            ) -> SearchResult {
                SearchResult(
                    kind: kind,
                    title: title,
                    subtitle: context,
                    coverImageId: game.coverImageId,
                    coverTint: tint,
                    wikiID: wiki.persistentModelID,
                    pageID: page?.persistentModelID
                )
            }

            if Self.matches(game.title, needle) {
                found.append(result(.game, game.title, game.releaseYear.map(String.init) ?? ""))
            }

            for page in wiki.pages.sorted(by: { $0.order < $1.order }) {
                if Self.matches(page.title, needle) {
                    found.append(result(.page, page.title, game.title, page: page))
                }

                for block in page.blocks.sorted(by: { $0.order < $1.order }) {
                    let context = "\(game.title) · \(page.title)"
                    switch block.type {
                    case .text:
                        if Self.matches(block.content, needle) {
                            found.append(result(
                                .text,
                                Self.snippet(of: block.content, around: needle),
                                context, page: page
                            ))
                        }
                    case .checklist:
                        let checklist = block.checklist
                        for item in checklist.items where Self.matches(item.text, needle) {
                            found.append(result(.checklistItem, item.text, context, page: page))
                        }
                    case .map:
                        for pin in block.map.pins where Self.matches(pin.label, needle) {
                            found.append(result(.mapPin, pin.label, context, page: page))
                        }
                    case .photo:
                        break
                    }
                }
            }
        }

        results = Array(found.prefix(Self.resultLimit))
    }

    // MARK: Navigation

    /// Résout la destination d'un résultat : le wiki, et la page quand le
    /// résultat en désigne une.
    func target(for result: SearchResult, context: ModelContext) -> ActivityTarget? {
        guard let wiki = context.model(for: result.wikiID) as? Wiki else { return nil }
        let page = result.pageID.flatMap { context.model(for: $0) as? Page }
        return ActivityTarget(wiki: wiki, page: page)
    }

    // MARK: Correspondance

    /// Comparaison insensible à la casse et aux accents.
    private static func matches(_ haystack: String, _ needle: String) -> Bool {
        haystack.range(of: needle, options: [.caseInsensitive, .diacriticInsensitive]) != nil
    }

    /// Extrait centré sur l'occurrence, tronqué de part et d'autre.
    private static func snippet(of text: String, around needle: String) -> String {
        guard let range = text.range(
            of: needle, options: [.caseInsensitive, .diacriticInsensitive]
        ) else {
            return String(text.prefix(snippetLength))
        }
        let start = text.index(
            range.lowerBound,
            offsetBy: -snippetLength / 3,
            limitedBy: text.startIndex
        ) ?? text.startIndex
        let end = text.index(
            range.upperBound,
            offsetBy: snippetLength * 2 / 3,
            limitedBy: text.endIndex
        ) ?? text.endIndex
        var snippet = String(text[start..<end]).trimmingCharacters(in: .whitespacesAndNewlines)
        if start > text.startIndex { snippet = "…" + snippet }
        if end < text.endIndex { snippet += "…" }
        return snippet
    }
}
