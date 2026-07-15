//
//  Color+Theme.swift
//  Grym
//
//  Palette brute du design system (tokens générés depuis le prototype).
//  Couche bas niveau : les vues ne référencent pas ces tokens directement,
//  elles passent par les rôles sémantiques de `Theme.Colors`.
//  Accent principal : Blue #3FC9E8
//

import SwiftUI

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

extension Color {

    // MARK: - Accent
    /// Accent principal de l'app (bleu)
    static let grymAccent       = Color(hex: 0x3FC9E8)   // Blue — accent actif
    static let grymAccentViolet = Color(hex: 0x7C6FF0)   // Violet (accent alternatif)
    static let grymAccentRose   = Color(hex: 0xE85C9E)
    static let grymAccentGreen  = Color(hex: 0x7AE582)
    /// Violet de marque historique (spec d'origine)
    static let grymBrand        = Color(hex: 0x534AB7)

    // MARK: - Fond (Dark)
    static let grymBgDark       = Color(hex: 0x0D0524)   // Fond principal sombre
    static let grymBgDeep       = Color(hex: 0x050113)   // Fond le plus sombre (dégradé)
    static let grymBgGlow       = Color(hex: 0x2A1560)   // Halo violet du dégradé
    static let grymCardDark     = Color(hex: 0x1A0E3A)   // Surface carte / élévation

    // MARK: - Fond (Light)
    static let grymBgLight      = Color(hex: 0xF4F3F8)
    static let grymBgLightAlt   = Color(hex: 0xF7F6FB)
    static let grymCardLight    = Color(hex: 0xFFFFFF)

    // MARK: - Texte
    static let grymTextPrimary  = Color(hex: 0xE9E8F5)   // Texte clair (dark mode)
    static let grymTextInverse  = Color(hex: 0x1A1625)   // Texte sombre (light mode)
    static let grymTextMuted    = Color(hex: 0xE9E8F5).opacity(0.55)

    // MARK: - Tiers de notation (Naze → GOTY)
    static let grymTierNaze     = Color(hex: 0x8A8794)   // Naze       (0–19)
    static let grymTierPasOuf   = Color(hex: 0xE07A5F)   // Pas ouf    (20–39)
    static let grymTierMid      = Color(hex: 0xF5C46B)   // Mid        (40–59)
    static let grymTierTopTier  = Color(hex: 0x7C6FF0)   // Top tier   (60–84)
    static let grymTierGOTY     = Color(hex: 0x3FC9E8)   // GOTY       (85–100)

    /// Retourne la couleur du tier pour une note 0–100
    static func grymTier(for note: Int) -> Color {
        switch note {
        case ..<20:  return .grymTierNaze
        case ..<40:  return .grymTierPasOuf
        case ..<60:  return .grymTierMid
        case ..<85:  return .grymTierTopTier
        default:     return .grymTierGOTY
        }
    }

    /// Teinte de repli déterministe pour une jaquette absente, dérivée d'une graine
    /// (hash stable entre lancements, contrairement à `String.hashValue`).
    static func grymTint(for seed: String) -> Color {
        let palette: [Color] = [
            .grymAccent, .grymAccentViolet, .grymAccentRose,
            .grymAccentGreen, .grymTierPasOuf, .grymTierMid
        ]
        let stable = seed.unicodeScalars.reduce(0) { $0 &+ Int($1.value) }
        return palette[stable % palette.count]
    }
}

// ───────────────────────────────────────────────────────────────
// Helpers
// ───────────────────────────────────────────────────────────────
extension Color {

    /// Init depuis un hex (0xRRGGBB).
    init(hex: UInt, alpha: Double = 1.0) {
        self.init(
            .sRGB,
            red:   Double((hex >> 16) & 0xFF) / 255.0,
            green: Double((hex >> 8)  & 0xFF) / 255.0,
            blue:  Double( hex        & 0xFF) / 255.0,
            opacity: alpha
        )
    }

    /// Couleur adaptative clair/sombre.
    init(light: Color, dark: Color) {
#if canImport(UIKit)
        self.init(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light)
        })
#elseif canImport(AppKit)
        self.init(nsColor: NSColor(name: nil) { appearance in
            appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                ? NSColor(dark) : NSColor(light)
        })
#else
        self = dark
#endif
    }
}
