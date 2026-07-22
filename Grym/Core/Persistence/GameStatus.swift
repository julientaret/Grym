//
//  GameStatus.swift
//  Grym
//
//  Statut de progression d'un jeu (backlog → platiné). Persisté en `String`
//  sur le wiki, robuste aux migrations comme `BlockType`.
//

import SwiftUI

enum GameStatus: String, CaseIterable, Identifiable {
    /// Aucun statut renseigné : valeur par défaut, masquée des badges.
    case none
    case backlog
    case playing
    case completed
    case platinum
    case abandoned

    var id: String { rawValue }

    /// Statuts proposés à la sélection, hors valeur neutre.
    static var assignable: [GameStatus] { allCases.filter { $0 != .none } }

    /// Clé de traduction du libellé.
    var nameKey: TranslationKey {
        switch self {
        case .none:      .statusNone
        case .backlog:   .statusBacklog
        case .playing:   .statusPlaying
        case .completed: .statusCompleted
        case .platinum:  .statusPlatinum
        case .abandoned: .statusAbandoned
        }
    }

    /// Icône SF Symbols du statut.
    var systemImage: String {
        switch self {
        case .none:      "circle.dashed"
        case .backlog:   "tray.full"
        case .playing:   "gamecontroller.fill"
        case .completed: "checkmark.seal.fill"
        case .platinum:  "trophy.fill"
        case .abandoned: "xmark.bin.fill"
        }
    }

    /// Couleur du statut (tokens fixes, indépendants du thème comme les tiers).
    var color: Color {
        switch self {
        case .none:      .grymTextMuted
        case .backlog:   .grymStatusBacklog
        case .playing:   .grymStatusPlaying
        case .completed: .grymStatusCompleted
        case .platinum:  .grymStatusPlatinum
        case .abandoned: .grymStatusAbandoned
        }
    }
}
