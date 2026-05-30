//
//  GrymVioletTheme.swift
//  Grym
//
//  Variante violette : accent #7C6FF0, halo renforcé. Démontre qu'un
//  nouveau thème ne surcharge que ses écarts par rapport à la base.
//

import SwiftUI

struct GrymVioletTheme: AppTheme {
    let id: ThemeID = .grymViolet
    let accent: Color = .grymAccentViolet
    let glow: Color = Color.grymAccentViolet.opacity(0.30)
}
