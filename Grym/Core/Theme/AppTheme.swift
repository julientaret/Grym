//
//  AppTheme.swift
//  Grym
//
//  Abstraction d'un thème de couleurs. Chaque thème concret fournit
//  ses rôles sémantiques ; des valeurs par défaut couvrent la base Grym
//  pour qu'un nouveau thème ne surcharge que ce qui change (souvent l'accent).
//

import SwiftUI

// MARK: - Identité des thèmes

/// Liste des thèmes disponibles. Ajouter un cas = exposer un nouveau thème.
enum ThemeID: String, CaseIterable, Identifiable {
    case grymBlue
    case grymViolet
    case grymEmerald
    case grymMagenta

    /// Thème disponible au palier gratuit ; les autres sont premium.
    static let free: ThemeID = .grymBlue

    var id: String { rawValue }

    /// Vrai si le thème nécessite le premium.
    var requiresPremium: Bool { self != Self.free }

    /// Clé de traduction du nom affiché.
    var nameKey: TranslationKey {
        switch self {
        case .grymBlue:    .themeGrymBlue
        case .grymViolet:  .themeGrymViolet
        case .grymEmerald: .themeGrymEmerald
        case .grymMagenta: .themeGrymMagenta
        }
    }

    /// Instancie le thème correspondant.
    func makeTheme() -> any AppTheme {
        switch self {
        case .grymBlue:    GrymBlueTheme()
        case .grymViolet:  GrymVioletTheme()
        case .grymEmerald: GrymEmeraldTheme()
        case .grymMagenta: GrymMagentaTheme()
        }
    }
}

// MARK: - Protocole

/// Rôles sémantiques de couleur d'un thème.
protocol AppTheme: Identifiable {
    var id: ThemeID { get }

    var accent: Color { get }
    var accentAlt: Color { get }
    var brand: Color { get }

    var background: Color { get }
    var backgroundDeep: Color { get }
    var surface: Color { get }
    var glow: Color { get }

    var primaryText: Color { get }
    var secondaryText: Color { get }

    /// Palette cyclée pour différencier les wikis d'un jeu (lignes, cartes).
    var pageAccents: [Color] { get }

    /// Couleur du tier de notation (0–100), du « Naze » au « GOTY ».
    func tier(for note: Int) -> Color
}

/// Valeurs par défaut (base Grym). Un thème concret ne surcharge que ses écarts.
extension AppTheme {
    var accentAlt: Color { .grymAccentViolet }
    var brand: Color { .grymBrand }

    var background: Color { Color(light: .grymBgLight, dark: .grymBgDark) }
    var backgroundDeep: Color { Color(light: .grymBgLightAlt, dark: .grymBgDeep) }
    var surface: Color { Color(light: .grymCardLight, dark: .grymCardDark) }
    var glow: Color { .grymBgGlow }

    var primaryText: Color { Color(light: .grymTextInverse, dark: .grymTextPrimary) }
    var secondaryText: Color {
        Color(light: .grymTextInverse.opacity(0.55), dark: .grymTextPrimary.opacity(0.55))
    }

    func tier(for note: Int) -> Color { Color.grymTier(for: note) }

    /// Par défaut, la palette des wikis tourne autour des accents du thème.
    var pageAccents: [Color] { [accent, accentAlt, brand, accent.opacity(0.7)] }
}

// MARK: - Environnement

private struct ThemeEnvironmentKey: EnvironmentKey {
    static let defaultValue: any AppTheme = GrymBlueTheme()
}

extension EnvironmentValues {
    /// Thème actif, lu par les vues via `@Environment(\.theme)`.
    var theme: any AppTheme {
        get { self[ThemeEnvironmentKey.self] }
        set { self[ThemeEnvironmentKey.self] = newValue }
    }
}
