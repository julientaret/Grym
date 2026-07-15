//
//  ScoreBadgeView.swift
//  Grym
//
//  Pastille de note personnelle (0–100), colorée selon le tier via le thème.
//

import SwiftUI

struct ScoreBadgeView: View {
    let score: Int
    @Environment(\.theme) private var theme

    var body: some View {
        Text("\(score)")
            .font(.system(size: Theme.FontSize.body, weight: .bold))
            .foregroundStyle(.white)
            .frame(width: 44, height: 34)
            .background(
                RoundedRectangle(cornerRadius: Theme.Radius.small, style: .continuous)
                    .fill(theme.tier(for: score))
            )
    }
}

#Preview {
    HStack(spacing: Theme.Spacing.medium) {
        ScoreBadgeView(score: 92)
        ScoreBadgeView(score: 76)
        ScoreBadgeView(score: 45)
        ScoreBadgeView(score: 15)
    }
    .padding()
    .background(Color.grymBgDark)
    .environment(\.theme, GrymBlueTheme())
}
