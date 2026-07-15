//
//  Date+Relative.swift
//  Grym
//
//  Formatage relatif d'une date (« il y a 2 h », « hier »…),
//  localisé automatiquement selon la locale active.
//

import Foundation

extension Date {

    private static let relativeFormatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter
    }()

    /// Description relative par rapport à maintenant (ex. « il y a 2 h »).
    var relativeDescription: String {
        Date.relativeFormatter.localizedString(for: self, relativeTo: Date())
    }
}
