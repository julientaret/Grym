//
//  GrymMagentaTheme.swift
//  Grym
//
//  Variante magenta (premium) : accent #E85C9E sur une base prune sombre.
//

import SwiftUI

struct GrymMagentaTheme: AppTheme {
    let id: ThemeID = .grymMagenta

    let accent: Color = .grymAccentRose
    let accentAlt: Color = .grymAccentAmber
    let brand = Color(hex: 0x9C2364)

    let background = Color(light: .grymMagentaBgLight, dark: .grymMagentaBgDark)
    let backgroundDeep = Color(light: .grymMagentaBgLightAlt, dark: .grymMagentaBgDeep)
    let surface = Color(light: .grymCardLight, dark: .grymMagentaCardDark)
    let glow: Color = .grymMagentaBgGlow

    let pageAccents: [Color] = [.grymAccentRose, .grymAccentAmber, .grymAccentLilac, .grymAccent]
}
