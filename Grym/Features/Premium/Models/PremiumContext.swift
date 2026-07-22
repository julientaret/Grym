//
//  PremiumContext.swift
//  Grym
//
//  D'où vient l'ouverture du paywall. Sert uniquement à expliquer,
//  en une phrase, ce qui vient d'être bloqué.
//

import Foundation

enum PremiumContext {
    /// Ouverture volontaire (depuis le Profil) : aucune raison à expliquer.
    case general
    /// Limite du palier gratuit atteinte à l'ajout d'un jeu.
    case gameLimit
    /// Thème verrouillé choisi dans le Profil.
    case theme
    /// Bilan complet demandé depuis l'accueil.
    case stats

    /// Phrase de contexte affichée sous le titre, `nil` si aucune.
    var reasonKey: TranslationKey? {
        switch self {
        case .general:   nil
        case .gameLimit: .premiumLimitReached
        case .theme:     .premiumReasonTheme
        case .stats:     .premiumReasonStats
        }
    }

    /// Icône du bandeau de contexte.
    var reasonIcon: String {
        switch self {
        case .general:   "sparkles"
        case .gameLimit: "tray.full.fill"
        case .theme:     "paintpalette.fill"
        case .stats:     "chart.bar.fill"
        }
    }
}
