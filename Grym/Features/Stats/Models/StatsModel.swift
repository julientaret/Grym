//
//  StatsModel.swift
//  Grym
//
//  Modèles de présentation du bilan personnel, calculés à partir de la
//  couche SwiftData (Wiki / Page / Block / PlaySession).
//

import SwiftUI

/// Une part d'une répartition (statuts, paliers de note).
struct BreakdownSlice: Identifiable, Hashable {
    let id: String
    /// Clé de traduction du libellé.
    let nameKey: TranslationKey
    let color: Color
    let count: Int
}

/// Un jeu dans un classement (meilleures notes, temps de jeu).
struct RankedGame: Identifiable, Hashable {
    let id: String
    let title: String
    let coverImageId: String?
    let coverTint: Color
    /// Valeur affichée à droite, déjà formatée.
    let value: String
}

/// Bilan complet de la collection.
struct LibraryStats {
    var gameCount: Int = 0
    var pageCount: Int = 0
    var blockCount: Int = 0
    var photoCount: Int = 0
    var checklistCount: Int = 0

    var sessionCount: Int = 0
    var totalPlayMinutes: Int = 0

    /// Note moyenne des jeux notés (score > 0), arrondie.
    var averageScore: Int = 0
    /// Nombre de jeux effectivement notés.
    var ratedCount: Int = 0

    var statusBreakdown: [BreakdownSlice] = []
    var tierBreakdown: [BreakdownSlice] = []
    var topRated: [RankedGame] = []
    var mostPlayed: [RankedGame] = []

    /// Durée moyenne d'une session, en minutes.
    var averageSessionMinutes: Int {
        sessionCount == 0 ? 0 : totalPlayMinutes / sessionCount
    }

    /// Vrai tant qu'aucun jeu n'a été ajouté.
    var isEmpty: Bool { gameCount == 0 }
}
