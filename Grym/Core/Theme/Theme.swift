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

    enum Colors {
        static let accent = Color.accentColor
        static let background = Color(.systemBackground)
        static let secondaryBackground = Color(.secondarySystemBackground)
        static let primaryText = Color.primary
        static let secondaryText = Color.secondary
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
