//
//  PremiumHUDLabel.swift
//  Grym
//
//  Petit libellé en capitales espacées, façon en-tête de menu de jeu.
//

import SwiftUI

struct PremiumHUDLabel: View {
    let text: String

    @Environment(\.theme) private var theme

    var body: some View {
        Text(text.uppercased())
            .font(.system(size: Theme.FontSize.caption - 1, weight: .bold, design: .rounded))
            .tracking(Theme.Tracking.hud)
            .foregroundStyle(theme.secondaryText)
    }
}

#Preview {
    PremiumHUDLabel(text: "Ce que ça débloque")
        .padding()
        .background(Color.grymBgDark)
        .environment(\.theme, GrymBlueTheme())
}
