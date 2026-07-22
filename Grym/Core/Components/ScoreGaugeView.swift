//
//  ScoreGaugeView.swift
//  Grym
//
//  Jauge circulaire de note personnelle (0–100), colorée selon le tier.
//  Partagée entre la ligne de la liste des jeux et la carte de note du détail.
//

import SwiftUI

struct ScoreGaugeView: View {
    let score: Int
    var diameter: CGFloat = Theme.Size.scoreGauge
    var lineWidth: CGFloat = 4
    /// Taille du nombre affiché au centre.
    var fontSize: CGFloat = Theme.FontSize.body

    @Environment(\.theme) private var theme

    private var tier: ScoreTier { ScoreTier.tier(for: score) }
    /// Une note à 0 correspond à un wiki non noté : jauge vide et tiret.
    private var isRated: Bool { score > 0 }
    private var color: Color { isRated ? tier.color : theme.secondaryText }

    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.2), lineWidth: lineWidth)

            if isRated {
                Circle()
                    .trim(from: 0, to: CGFloat(score) / 100)
                    .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                    .rotationEffect(.degrees(-90))
            }

            Text(isRated ? "\(score)" : "–")
                .font(.system(size: fontSize, weight: .bold, design: .rounded))
                .foregroundStyle(color)
                .contentTransition(.numericText())
                .minimumScaleFactor(0.7)
                .lineLimit(1)
                .padding(.horizontal, lineWidth)
        }
        .frame(width: diameter, height: diameter)
        .animation(.easeInOut(duration: Theme.AnimationDuration.fast), value: score)
    }
}

#Preview("Dark") {
    gaugePreview
        .background(Color.grymBgDark)
        .preferredColorScheme(.dark)
}

#Preview("Light") {
    gaugePreview
        .background(Color.grymBgLight)
        .preferredColorScheme(.light)
}

private var gaugePreview: some View {
    VStack(spacing: Theme.Spacing.large) {
        HStack(spacing: Theme.Spacing.medium) {
            ForEach([0, 15, 45, 76, 92], id: \.self) { ScoreGaugeView(score: $0) }
        }
        ScoreGaugeView(score: 92, diameter: Theme.Size.scoreGaugeLarge,
                       lineWidth: 6, fontSize: Theme.FontSize.title + 6)
    }
    .padding()
    .environment(\.theme, GrymBlueTheme())
}
