//
//  StatTileView.swift
//  Grym
//
//  Tuile d'une statistique : valeur mise en avant, libellé et icône.
//

import SwiftUI

struct StatTileView: View {
    let systemImage: String
    let value: String
    let label: String
    var accent: Color?

    @Environment(\.theme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xSmall) {
            Image(systemName: systemImage)
                .font(.system(size: Theme.FontSize.caption, weight: .bold))
                .foregroundStyle(accent ?? theme.accent)

            Text(value)
                .font(.system(size: Theme.FontSize.title, weight: .bold))
                .foregroundStyle(theme.primaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.6)

            Text(label)
                .font(.system(size: Theme.FontSize.caption, weight: .regular))
                .foregroundStyle(theme.secondaryText)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Theme.Spacing.medium)
        .background(
            RoundedRectangle(cornerRadius: Theme.Radius.medium, style: .continuous)
                .fill(theme.surface.opacity(0.5))
        )
    }
}

#Preview {
    HStack {
        StatTileView(systemImage: "gamecontroller", value: "24", label: "Jeux")
        StatTileView(systemImage: "hourglass", value: "312 h", label: "Temps de jeu")
    }
    .padding()
    .background(Color.grymBgDark)
    .environment(\.theme, GrymBlueTheme())
}
