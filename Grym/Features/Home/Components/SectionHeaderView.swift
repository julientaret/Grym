//
//  SectionHeaderView.swift
//  Grym
//
//  En-tête de section réutilisable : icône accentuée + titre,
//  avec un compteur optionnel aligné à droite.
//

import SwiftUI

struct SectionHeaderView: View {
    let systemImage: String
    let title: String
    var trailingCount: Int? = nil

    @Environment(\.theme) private var theme

    var body: some View {
        HStack(spacing: Theme.Spacing.small) {
            Image(systemName: systemImage)
                .font(.system(size: Theme.FontSize.caption, weight: .bold))
                .foregroundStyle(theme.accent)

            Text(title)
                .font(.system(size: Theme.FontSize.body, weight: .semibold))
                .foregroundStyle(theme.primaryText)

            Spacer()

            if let trailingCount {
                Text("\(trailingCount)")
                    .font(.system(size: Theme.FontSize.caption, weight: .semibold))
                    .foregroundStyle(theme.secondaryText)
            }
        }
    }
}

#Preview {
    VStack(spacing: Theme.Spacing.large) {
        SectionHeaderView(systemImage: "pin.fill", title: "Épinglés", trailingCount: 7)
        SectionHeaderView(systemImage: "sparkles", title: "Activité récente")
    }
    .padding()
    .background(Color.grymBgDark)
    .environment(\.theme, GrymBlueTheme())
}
