//
//  GrymEmeraldTheme.swift
//  Grym
//
//  Variante émeraude (premium) : accent #2CD4A0 sur une base vert profond.
//

import SwiftUI

struct GrymEmeraldTheme: AppTheme {
    let id: ThemeID = .grymEmerald

    let accent: Color = .grymAccentEmerald
    let accentAlt: Color = .grymAccentTeal
    let brand = Color(hex: 0x0E7A5A)

    let background = Color(light: .grymEmeraldBgLight, dark: .grymEmeraldBgDark)
    let backgroundDeep = Color(light: .grymEmeraldBgLightAlt, dark: .grymEmeraldBgDeep)
    let surface = Color(light: .grymCardLight, dark: .grymEmeraldCardDark)
    let glow: Color = .grymEmeraldBgGlow

    let pageAccents: [Color] = [.grymAccentEmerald, .grymAccentTeal, .grymAccentGreen, .grymAccentAmber]
}
