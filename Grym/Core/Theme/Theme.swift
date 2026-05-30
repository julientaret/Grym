//
//  Theme.swift
//  Grym
//
//  Centralise les valeurs réutilisables du design system :
//  couleurs, spacings, font sizes, radius et durées d'animation.
//

import SwiftUI

enum Theme {

    // MARK: - Couleurs
    //
    // Rôles sémantiques du design system. Les vues référencent uniquement
    // ces valeurs, jamais les tokens bruts `Color.grym*` (cf. Color+Theme.swift).

    enum Colors {
        // Accent / marque
        static let accent = Color.grymAccent
        static let accentAlt = Color.grymAccentViolet
        static let brand = Color.grymBrand

        // Fonds (adaptatifs clair/sombre)
        static let background = Color(light: .grymBgLight, dark: .grymBgDark)
        static let backgroundDeep = Color(light: .grymBgLightAlt, dark: .grymBgDeep)
        static let surface = Color(light: .grymCardLight, dark: .grymCardDark)
        /// Halo violet utilisé dans les dégradés de fond.
        static let glow = Color.grymBgGlow

        // Textes (adaptatifs clair/sombre)
        static let primaryText = Color(light: .grymTextInverse, dark: .grymTextPrimary)
        static let secondaryText = Color(
            light: .grymTextInverse.opacity(0.55),
            dark: .grymTextPrimary.opacity(0.55)
        )

        /// Couleur du tier de notation (0–100), du « Naze » au « GOTY ».
        static func tier(for note: Int) -> Color { Color.grymTier(for: note) }
    }

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
    }

    // MARK: - Radius

    enum Radius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 20
    }

    // MARK: - Durées d'animation

    enum AnimationDuration {
        static let fast: Double = 0.2
        static let medium: Double = 0.35
    }
}
