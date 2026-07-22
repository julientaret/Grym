//
//  WikiLink.swift
//  Grym
//
//  Liens internes entre pages d'un même wiki, écrits `[[Titre de page]]`
//  dans les blocs texte. Analyse du balisage et rendu en texte attribué.
//

import SwiftData
import SwiftUI

enum WikiLink {

    /// Balisage d'un lien vers une page.
    static func markup(for title: String) -> String { "[[\(title)]]" }

    /// Titres de page référencés dans un texte, dans l'ordre d'apparition.
    static func targets(in text: String) -> [String] {
        matches(in: text).map(\.title)
    }

    /// Vrai si le texte contient au moins un lien.
    static func containsLink(_ text: String) -> Bool {
        !matches(in: text).isEmpty
    }

    /// Texte attribué où chaque lien est coloré et cliquable.
    /// `resolve` indique si la page ciblée existe : les liens cassés sont
    /// affichés en `brokenColor` mais restent cliquables (création à la volée).
    static func attributed(
        _ text: String,
        resolve: (String) -> Bool,
        linkColor: Color,
        brokenColor: Color
    ) -> AttributedString {
        var result = AttributedString()
        var cursor = text.startIndex

        for match in matches(in: text) {
            result.append(AttributedString(String(text[cursor..<match.range.lowerBound])))

            var link = AttributedString(match.title)
            link.foregroundColor = resolve(match.title) ? linkColor : brokenColor
            link.underlineStyle = .single
            link.link = url(for: match.title)
            result.append(link)

            cursor = match.range.upperBound
        }

        result.append(AttributedString(String(text[cursor...])))
        return result
    }

    // MARK: URL interne

    /// Schéma interne : intercepté par la vue, jamais ouvert par le système.
    private static let scheme = "grym"
    private static let host = "page"

    static func url(for title: String) -> URL? {
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.queryItems = [URLQueryItem(name: "title", value: title)]
        return components.url
    }

    /// Titre de page ciblé par une URL interne, `nil` si l'URL n'en est pas une.
    static func title(from url: URL) -> String? {
        guard url.scheme == scheme, url.host == host else { return nil }
        return URLComponents(url: url, resolvingAgainstBaseURL: false)?
            .queryItems?.first(where: { $0.name == "title" })?.value
    }

    // MARK: Analyse

    private struct Match {
        let title: String
        let range: Range<String.Index>
    }

    /// Occurrences de `[[…]]` dans un texte, titres vides ignorés.
    private static func matches(in text: String) -> [Match] {
        let pattern = /\[\[([^\[\]\n]+)\]\]/
        return text.matches(of: pattern).compactMap { match in
            let title = String(match.output.1).trimmingCharacters(in: .whitespaces)
            guard !title.isEmpty else { return nil }
            return Match(title: title, range: match.range)
        }
    }
}

// MARK: - Résolution dans un wiki

extension Wiki {
    /// Page portant ce titre (comparaison insensible à la casse et aux accents).
    func page(titled title: String) -> Page? {
        pages.first {
            $0.title.compare(title, options: [.caseInsensitive, .diacriticInsensitive])
                == .orderedSame
        }
    }
}

extension Page {
    /// Titres de page référencés par les blocs texte de cette page.
    var linkedTitles: [String] {
        blocks
            .filter { $0.type == .text }
            .flatMap { WikiLink.targets(in: $0.content) }
    }

    /// Pages du même wiki qui pointent vers celle-ci (rétroliens).
    var backlinks: [Page] {
        guard let wiki else { return [] }
        return wiki.pages
            .filter { $0.persistentModelID != persistentModelID }
            .filter { candidate in
                candidate.linkedTitles.contains {
                    $0.compare(title, options: [.caseInsensitive, .diacriticInsensitive])
                        == .orderedSame
                }
            }
            .sorted { $0.order < $1.order }
    }
}
