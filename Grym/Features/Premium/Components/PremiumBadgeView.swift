//
//  PremiumBadgeView.swift
//  Grym
//
//  Badge du paywall façon trophée de jeu : anneau d'accent en rotation lente,
//  halo, et pastille trophée (coche une fois le premium acquis).
//

import SwiftUI

struct PremiumBadgeView: View {
    let isUnlocked: Bool

    @Environment(\.theme) private var theme
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isSpinning = false

    private var size: CGFloat { Theme.Size.premiumCrest }

    var body: some View {
        ZStack {
            halo
            ring
            crest
        }
        .frame(width: size * 2, height: size * 2)
        .onAppear { isSpinning = !reduceMotion }
    }

    /// Le halo du thème étant sombre, il devient une aura d'accent en thème clair.
    private var halo: some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: colorScheme == .light
                        ? [theme.accent.opacity(0.22), .clear]
                        : [theme.glow.opacity(0.9), .clear],
                    center: .center, startRadius: 0, endRadius: size
                )
            )
    }

    /// Anneau segmenté qui tourne : le « chargement » d'un écran de trophée.
    private var ring: some View {
        Circle()
            .strokeBorder(
                AngularGradient(
                    colors: [theme.accent.opacity(0), theme.accent, theme.accentAlt,
                             theme.accent.opacity(0)],
                    center: .center
                ),
                lineWidth: Theme.Size.premiumRingWidth
            )
            .frame(width: size * 1.5, height: size * 1.5)
            .rotationEffect(.degrees(isSpinning ? 360 : 0))
            .animation(
                reduceMotion ? nil : .linear(duration: 9).repeatForever(autoreverses: false),
                value: isSpinning
            )
    }

    private var crest: some View {
        Circle()
            .fill(
                LinearGradient(colors: [theme.accent, theme.accentAlt],
                               startPoint: .topLeading, endPoint: .bottomTrailing)
            )
            .frame(width: size, height: size)
            .overlay(
                Image(systemName: isUnlocked ? "checkmark" : "trophy.fill")
                    .font(.system(size: Theme.FontSize.title, weight: .bold))
                    .foregroundStyle(.white)
            )
            .shadow(color: theme.accent.opacity(0.5), radius: 16, y: 6)
    }
}

#Preview {
    HStack(spacing: Theme.Spacing.large) {
        PremiumBadgeView(isUnlocked: false)
        PremiumBadgeView(isUnlocked: true)
    }
    .padding()
    .background(Color.grymBgDark)
    .environment(\.theme, GrymBlueTheme())
}
