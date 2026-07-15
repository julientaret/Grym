//
//  ScoreTier.swift
//  Grym
//
//  Palier de la note personnelle (0–100), du « Naze » au « GOTY ».
//  Fournit rang, libellé et couleur pour l'affichage.
//

import SwiftUI

enum ScoreTier: Int, CaseIterable, Identifiable {
    case naze
    case pasOuf
    case mid
    case topTier
    case goty

    var id: Int { rawValue }

    /// Palier correspondant à une note 0–100.
    static func tier(for score: Int) -> ScoreTier {
        switch score {
        case ..<20:  .naze
        case ..<40:  .pasOuf
        case ..<60:  .mid
        case ..<85:  .topTier
        default:     .goty
        }
    }

    /// Rang affiché (1 à 5).
    var rank: Int { rawValue + 1 }

    /// Nombre total de paliers.
    static var count: Int { allCases.count }

    /// Clé de traduction du libellé.
    var nameKey: TranslationKey {
        switch self {
        case .naze:    .tierNaze
        case .pasOuf:  .tierPasOuf
        case .mid:     .tierMid
        case .topTier: .tierTopTier
        case .goty:    .tierGoty
        }
    }

    /// Couleur du palier.
    var color: Color {
        switch self {
        case .naze:    .grymTierNaze
        case .pasOuf:  .grymTierPasOuf
        case .mid:     .grymTierMid
        case .topTier: .grymTierTopTier
        case .goty:    .grymTierGOTY
        }
    }
}
