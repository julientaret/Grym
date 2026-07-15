//
//  WikiScoreCard.swift
//  Grym
//
//  Carte « Note personnelle » : gros score, palier, et slider 0–100
//  à dégradé de tiers. Note strictement privée (jamais partagée).
//

import SwiftUI

struct WikiScoreCard: View {
    @Binding var score: Int
    /// Appelé en fin d'interaction (persistance).
    var onCommit: () -> Void

    @EnvironmentObject private var localization: LocalizationManager
    @Environment(\.theme) private var theme

    /// Score au début du drag, pour ajuster par translation (robuste aux
    /// événements de geste fantômes émis pendant les transitions).
    @State private var dragStartScore: Int?

    private var tier: ScoreTier { ScoreTier.tier(for: score) }
    private let thumbSize: CGFloat = 26

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.medium) {
            header
            slider
            tierLabels
        }
        .padding(Theme.Spacing.large)
        .background(
            RoundedRectangle(cornerRadius: Theme.Radius.large, style: .continuous)
                .fill(theme.surface.opacity(0.5))
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.Radius.large, style: .continuous)
                        .stroke(.white.opacity(0.06), lineWidth: 1)
                )
        )
    }

    // MARK: En-tête de carte

    private var header: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.small) {
            HStack {
                Text(localization.string(.wikiNoteTitle))
                    .font(.system(size: Theme.FontSize.caption, weight: .semibold))
                    .foregroundStyle(theme.secondaryText)
                    .tracking(1)
                Spacer()
                Text(localization.string(.wikiNeverShared))
                    .font(.system(size: Theme.FontSize.caption, weight: .semibold))
                    .foregroundStyle(theme.secondaryText)
                    .tracking(1)
            }

            HStack(alignment: .firstTextBaseline) {
                Text("\(score)")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundStyle(theme.primaryText)
                    .contentTransition(.numericText())

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: Theme.Spacing.xSmall) {
                        Circle().fill(tier.color).frame(width: 8, height: 8)
                        Text(localization.string(tier.nameKey))
                            .font(.system(size: Theme.FontSize.body, weight: .bold))
                            .foregroundStyle(tier.color)
                    }
                    Text("\(localization.string(.wikiTierLabel)) \(tier.rank) / \(ScoreTier.count)")
                        .font(.system(size: Theme.FontSize.caption, weight: .medium))
                        .foregroundStyle(theme.secondaryText)
                }

                Spacer()

                Text(localization.string(.wikiPrivate))
                    .font(.system(size: Theme.FontSize.caption, weight: .semibold))
                    .foregroundStyle(theme.secondaryText)
                    .tracking(1)
            }
        }
    }

    // MARK: Slider custom

    private var slider: some View {
        GeometryReader { geo in
            let usable = max(geo.size.width - thumbSize, 1)
            let fraction = CGFloat(score) / 100
            let x = thumbSize / 2 + usable * fraction

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(theme.secondaryText.opacity(0.2))
                    .frame(height: 6)

                Capsule()
                    .fill(LinearGradient(
                        colors: ScoreTier.allCases.map(\.color),
                        startPoint: .leading, endPoint: .trailing))
                    .frame(width: x, height: 6)

                Circle()
                    .fill(.white)
                    .frame(width: thumbSize, height: thumbSize)
                    .overlay(Circle().stroke(tier.color, lineWidth: 3))
                    .shadow(color: .black.opacity(0.3), radius: 3, y: 1)
                    .offset(x: x - thumbSize / 2)
            }
            .frame(maxHeight: .infinity)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 1)
                    .onChanged { value in
                        let base = dragStartScore ?? score
                        if dragStartScore == nil { dragStartScore = base }
                        let delta = Double(value.translation.width / usable) * 100
                        let newScore = min(max(0, Int((Double(base) + delta).rounded())), 100)
                        if newScore != score {
                            score = newScore
                        }
                    }
                    .onEnded { _ in
                        dragStartScore = nil
                        onCommit()
                    }
            )
        }
        .frame(height: thumbSize)
    }

    // MARK: Libellés de paliers

    private var tierLabels: some View {
        HStack(spacing: 0) {
            ForEach(ScoreTier.allCases) { t in
                Text(localization.string(t.nameKey))
                    .font(.system(size: 10, weight: t == tier ? .bold : .medium))
                    .foregroundStyle(t == tier ? tier.color : theme.secondaryText)
                    .frame(maxWidth: .infinity)
            }
        }
    }
}

#Preview {
    WikiScoreCard(score: .constant(76), onCommit: {})
        .padding()
        .background(Color.grymBgDark)
        .environmentObject(LocalizationManager())
        .environment(\.theme, GrymBlueTheme())
}
