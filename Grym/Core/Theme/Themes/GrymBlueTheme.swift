//
//  GrymBlueTheme.swift
//  Grym
//
//  Thème par défaut (gratuit) : accent cyan #3FC9E8 sur une base bleu nuit.
//

import SwiftUI

struct GrymBlueTheme: AppTheme {
    let id: ThemeID = .grymBlue

    let accent: Color = .grymAccent
    let accentAlt: Color = .grymAccentSky
    let brand = Color(hex: 0x1F6FB2)

    let background = Color(light: .grymBlueBgLight, dark: .grymBlueBgDark)
    let backgroundDeep = Color(light: .grymBlueBgLightAlt, dark: .grymBlueBgDeep)
    let surface = Color(light: .grymCardLight, dark: .grymBlueCardDark)
    let glow: Color = .grymBlueBgGlow

    let pageAccents: [Color] = [.grymAccent, .grymAccentSky, .grymAccentTeal, .grymAccentEmerald]
}
