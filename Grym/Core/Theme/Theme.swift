//
//  Theme.swift
//  Grym
//
//  Centralise les valeurs réutilisables du design system :
//  couleurs, spacings, font sizes, radius et durées d'animation.
//

import SwiftUI

enum Theme {

    // Les couleurs sont fournies par le thème actif (cf. AppTheme / ThemeManager),
    // lu dans les vues via `@Environment(\.theme)`. Les constantes ci-dessous
    // sont indépendantes du thème.

    // MARK: - Spacings

    enum Spacing {
        static let xSmall: CGFloat = 4
        static let small: CGFloat = 8
        static let medium: CGFloat = 16
        static let large: CGFloat = 24
        static let xLarge: CGFloat = 32
    }

    // MARK: - Font sizes

    enum FontSize {
        static let caption: CGFloat = 12
        static let body: CGFloat = 16
        static let title: CGFloat = 22
        static let largeTitle: CGFloat = 34
        /// Chiffre mis en avant (temps de jeu du bilan).
        static let hero: CGFloat = 44
    }

    // MARK: - Radius

    enum Radius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 20
    }

    // MARK: - Dimensions

    enum Size {
        /// Hauteur des bannières illustrées d'en-tête d'onglet.
        static let bannerHeight: CGFloat = 260
        /// Variante réduite, pour les écrans dont le contenu prime sur l'illustration.
        static let bannerHeightCompact: CGFloat = 180
        /// Pastille d'humeur d'une ligne de session.
        static let sessionMoodIcon: CGFloat = 36
        /// Vignette de jaquette d'un résultat de recherche.
        static let searchThumbnail: CGFloat = 44
        /// Hauteur de la barre de répartition du bilan.
        static let breakdownBarHeight: CGFloat = 14
        /// Vignette de jaquette d'une ligne de classement.
        static let rankingThumbnail: CGFloat = 40
        /// Pastille d'icône de l'en-tête du bilan.
        static let statsHeroIcon: CGFloat = 52
    }

    // MARK: - Seuils d'affichage

    enum Limit {
        /// Sessions visibles dans le journal avant « Tout afficher ».
        static let visibleSessions = 3
    }

    // MARK: - Durées d'animation

    enum AnimationDuration {
        static let fast: Double = 0.2
        static let medium: Double = 0.35
    }
}
