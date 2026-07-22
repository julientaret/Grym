//
//  PremiumBackgroundView.swift
//  Grym
//
//  Fond du paywall façon menu de jeu : dégradé du thème, halo haut et
//  grille en fuite vers l'horizon, estompée avant le contenu.
//

import SwiftUI

struct PremiumBackgroundView: View {
    @Environment(\.theme) private var theme
    @Environment(\.colorScheme) private var colorScheme

    private var isLight: Bool { colorScheme == .light }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [theme.backgroundDeep, theme.background],
                startPoint: .top, endPoint: .bottom
            )

            // Le halo du thème est une couleur sombre : en clair, il tacherait
            // le haut de l'écran. On l'y remplace par un voile blanc légèrement teinté.
            RadialGradient(
                colors: isLight
                    ? [.white, theme.accent.opacity(0.12), .clear]
                    : [theme.glow.opacity(0.55), .clear],
                center: UnitPoint(x: 0.5, y: 0.02),
                startRadius: 4, endRadius: 380
            )

            grid
        }
        .ignoresSafeArea()
    }

    /// Grille en perspective : lignes de fuite + traverses resserrées vers l'horizon.
    private var grid: some View {
        Canvas { context, size in
            let horizon = size.height * 0.62
            let color = theme.accent.opacity(isLight ? 0.22 : 0.16)
            var path = Path()

            // Lignes de fuite, toutes vers le point central de l'horizon.
            let vanishing = CGPoint(x: size.width / 2, y: horizon)
            for step in -Self.rays...Self.rays {
                let spread = CGFloat(step) / CGFloat(Self.rays)
                path.move(to: vanishing)
                path.addLine(to: CGPoint(x: size.width / 2 + spread * size.width * 2.4,
                                         y: size.height))
            }

            // Traverses : espacement géométrique pour simuler la profondeur.
            var offset: CGFloat = 6
            var spacing: CGFloat = 6
            while horizon + offset < size.height {
                let y = horizon + offset
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: size.width, y: y))
                spacing *= 1.32
                offset += spacing
            }

            context.stroke(path, with: .color(color), lineWidth: 1)
        }
        .mask(
            LinearGradient(colors: [.clear, .white.opacity(0.9), .clear],
                           startPoint: .init(x: 0.5, y: 0.62),
                           endPoint: .bottom)
        )
        // En clair, `plusLighter` effacerait la grille sur un fond quasi blanc.
        .blendMode(isLight ? .normal : .plusLighter)
        .allowsHitTesting(false)
    }

    /// Nombre de lignes de fuite de chaque côté de l'axe.
    private static let rays = 7
}

#Preview {
    PremiumBackgroundView()
        .environment(\.theme, GrymBlueTheme())
}
