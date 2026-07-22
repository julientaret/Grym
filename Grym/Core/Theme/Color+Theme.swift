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

    // MARK: - Fond (Dark) — base violette, thème par défaut
    static let grymBgDark       = Color(hex: 0x0D0524)   // Fond principal sombre
    static let grymBgDeep       = Color(hex: 0x050113)   // Fond le plus sombre (dégradé)
    static let grymBgGlow       = Color(hex: 0x2A1560)   // Halo violet du dégradé
    static let grymCardDark     = Color(hex: 0x1A0E3A)   // Surface carte / élévation

    // MARK: - Fond (Light) — base violette
    static let grymBgLight      = Color(hex: 0xF4F3F8)
    static let grymBgLightAlt   = Color(hex: 0xF7F6FB)
    static let grymCardLight    = Color(hex: 0xFFFFFF)

    // Chaque thème teinte sa propre base : le changement se voit sur les fonds,
    // le halo et les surfaces, pas seulement sur la couleur d'accent.

    // MARK: - Fond Bleu nuit
    static let grymBlueBgDark     = Color(hex: 0x061826)
    static let grymBlueBgDeep     = Color(hex: 0x020A12)
    static let grymBlueBgGlow     = Color(hex: 0x0E4A6B)
    static let grymBlueCardDark   = Color(hex: 0x0E2C42)
    static let grymBlueBgLight    = Color(hex: 0xEFF4F9)
    static let grymBlueBgLightAlt = Color(hex: 0xF6FAFD)

    // MARK: - Fond Émeraude
    static let grymEmeraldBgDark     = Color(hex: 0x04201A)
    static let grymEmeraldBgDeep     = Color(hex: 0x010F0B)
    static let grymEmeraldBgGlow     = Color(hex: 0x0B5B44)
    static let grymEmeraldCardDark   = Color(hex: 0x0A3329)
    static let grymEmeraldBgLight    = Color(hex: 0xEFF6F2)
    static let grymEmeraldBgLightAlt = Color(hex: 0xF6FBF8)

    // MARK: - Fond Magenta
    static let grymMagentaBgDark     = Color(hex: 0x21071A)
    static let grymMagentaBgDeep     = Color(hex: 0x11030D)
    static let grymMagentaBgGlow     = Color(hex: 0x66134A)
    static let grymMagentaCardDark   = Color(hex: 0x361029)
    static let grymMagentaBgLight    = Color(hex: 0xFAF0F6)
    static let grymMagentaBgLightAlt = Color(hex: 0xFDF7FA)

    // MARK: - Accents secondaires par famille
    static let grymAccentEmerald = Color(hex: 0x2CD4A0)
    static let grymAccentTeal    = Color(hex: 0x33B6C9)
    static let grymAccentSky     = Color(hex: 0x5B9DF5)
    static let grymAccentAmber   = Color(hex: 0xF5A65B)
    static let grymAccentLilac   = Color(hex: 0xB07CF0)

    // MARK: - Texte
    static let grymTextPrimary  = Color(hex: 0xE9E8F5)   // Texte clair (dark mode)
    static let grymTextInverse  = Color(hex: 0x1A1625)   // Texte sombre (light mode)
    static let grymTextMuted    = Color(hex: 0xE9E8F5).opacity(0.55)

    // MARK: - Tiers de notation (Naze → GOTY)
    // Comme les statuts : teintes claires en dark mode, variantes assombries
    // en light mode pour rester lisibles sur fond clair.
    static let grymTierNaze     = Color(light: Color(hex: 0x5C5966), dark: Color(hex: 0x8A8794))
    static let grymTierPasOuf   = Color(light: Color(hex: 0xAC3D26), dark: Color(hex: 0xE07A5F))
    static let grymTierMid      = Color(light: Color(hex: 0x8A5D0C), dark: Color(hex: 0xF5C46B))
    static let grymTierTopTier  = Color(light: Color(hex: 0x4B3FC4), dark: Color(hex: 0x7C6FF0))
    static let grymTierGOTY     = Color(light: Color(hex: 0x0B7089), dark: Color(hex: 0x3FC9E8))

    // MARK: - Statuts de progression (cf. GameStatus)
    // Les teintes claires sont pensées pour un fond sombre ; en light mode on
    // bascule sur des variantes assombries pour conserver un contraste lisible.
    static let grymStatusBacklog   = Color(hex: 0x8A93A8)   // À jouer
    static let grymStatusPlaying   = Color(hex: 0x3FC9E8)   // En cours
    static let grymStatusCompleted = Color(hex: 0x7AE582)   // Terminé
    static let grymStatusPlatinum  = Color(hex: 0xF5C46B)   // Platiné / 100 %
    static let grymStatusAbandoned = Color(hex: 0xE07A5F)   // Abandonné

    static let grymStatusBacklogLight   = Color(hex: 0x4E5771)
    static let grymStatusPlayingLight   = Color(hex: 0x0B7089)
    static let grymStatusCompletedLight = Color(hex: 0x1C7F3B)
    static let grymStatusPlatinumLight  = Color(hex: 0x8A5D0C)
    static let grymStatusAbandonedLight = Color(hex: 0xAC3D26)

    // MARK: - Humeurs de session (cf. SessionMood)
    static let grymMoodHyped   = Color(hex: 0x7AE582)
    static let grymMoodGood    = Color(hex: 0x3FC9E8)
    static let grymMoodNeutral = Color(hex: 0xF5C46B)
    static let grymMoodRough   = Color(hex: 0xE07A5F)

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
