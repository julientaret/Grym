//
//  Int+Playtime.swift
//  Grym
//
//  Formatage d'une durée de jeu exprimée en minutes.
//

import Foundation

extension Int {
    /// Formate un nombre de minutes en durée lisible : « 2 h 30 », « 45 min ».
    /// Les unités sont fournies par l'appelant (localisées).
    func playtimeLabel(hourUnit: String, minuteUnit: String) -> String {
        let hours = self / 60
        let minutes = self % 60
        switch (hours, minutes) {
        case (0, _):  return "\(minutes) \(minuteUnit)"
        case (_, 0):  return "\(hours) \(hourUnit)"
        default:      return "\(hours) \(hourUnit) \(minutes)"
        }
    }
}
