//
//  GrymVioletTheme.swift
//  Grym
//
//  Variante violette (premium) : accent #7C6FF0 sur la base violette
//  historique de Grym. Ne surcharge pas les fonds : ce sont ceux par défaut.
//

import SwiftUI

struct GrymVioletTheme: AppTheme {
    let id: ThemeID = .grymViolet

    let accent: Color = .grymAccentViolet
    let accentAlt: Color = .grymAccentLilac
    let brand: Color = .grymBrand

    let glow: Color = .grymBgGlow

    let pageAccents: [Color] = [.grymAccentViolet, .grymAccentLilac, .grymAccentRose, .grymAccent]
}
