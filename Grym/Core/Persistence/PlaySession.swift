//
//  PlaySession.swift
//  Grym
//
//  Session de jeu consignée par l'utilisateur : date, durée, ressenti et
//  note libre. Alimente le journal du wiki et le temps de jeu cumulé.
//

import Foundation
import SwiftData

@Model
final class PlaySession {
    var wiki: Wiki?
    /// Date de la session (jour choisi par l'utilisateur).
    var date: Date
    /// Durée en minutes.
    var minutes: Int
    /// Ressenti persisté ; exposé via la propriété calculée `mood`.
    var moodRaw: String
    /// Note libre facultative (« boss battu », « fin du chapitre 3 »…).
    var note: String
    var createdAt: Date

    init(
        date: Date = Date(),
        minutes: Int = 60,
        mood: SessionMood = .good,
        note: String = ""
    ) {
        self.date = date
        self.minutes = minutes
        self.moodRaw = mood.rawValue
        self.note = note
        self.createdAt = Date()
    }

    /// Ressenti de la session (repli sur `.good` si valeur inconnue).
    var mood: SessionMood {
        get { SessionMood(rawValue: moodRaw) ?? .good }
        set { moodRaw = newValue.rawValue }
    }
}

// MARK: - Durées proposées

extension PlaySession {
    /// Heures proposées dans l'éditeur de session.
    static let hourChoices = Array(0...12)
    /// Minutes proposées, par quart d'heure.
    static let minuteChoices = [0, 15, 30, 45]
}
