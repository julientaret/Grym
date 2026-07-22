//
//  ThemeSwatchView.swift
//  Grym
//
//  Vignette d'un thème : mini-maquette de l'app (bandeau, jaquette, carte,
//  pastille de note et accents), nom clin d'œil, punchline, état sélectionné
//  et badge premium si le thème est verrouillé.
//

import SwiftUI

struct ThemeSwatchView: View {
    let themeID: ThemeID
    let isSelected: Bool
    let isLocked: Bool

    @EnvironmentObject private var localization: LocalizationManager
    /// Thème actif de l'app : sert au texte et à la bordure de sélection,
    /// pendant que la vignette montre le thème `themeID`.
    @Environment(\.theme) private var currentTheme

    private var preview: any AppTheme { themeID.makeTheme() }

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.small) {
            swatch
            caption
        }
    }

    // MARK: Légende

    private var caption: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: Theme.Spacing.xSmall) {
                Text(localization.string(themeID.nameKey))
                    .font(.system(size: Theme.FontSize.caption + 1, weight: .bold))
                    .foregroundStyle(currentTheme.primaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                Spacer(minLength: 0)

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: Theme.FontSize.caption + 1, weight: .semibold))
                        .foregroundStyle(currentTheme.accent)
                }
            }

            Text(localization.string(themeID.taglineKey))
                .font(.system(size: Theme.FontSize.caption - 2))
                .foregroundStyle(currentTheme.secondaryText)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    // MARK: Aperçu

    private var swatch: some View {
        ZStack {
            LinearGradient(
                colors: [preview.backgroundDeep, preview.background],
                startPoint: .top,
                endPoint: .bottom
            )

            RadialGradient(
                colors: [preview.glow.opacity(0.8), .clear],
                center: UnitPoint(x: 0.5, y: 0.0),
                startRadius: 2,
                endRadius: 96
            )

            mockup
        }
        .frame(height: Theme.Size.themeSwatchHeight)
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.medium, style: .continuous))
        .overlay(selectionBorder)
        .overlay { if isLocked { lockOverlay } }
        .shadow(
            color: isSelected ? currentTheme.accent.opacity(0.35) : .clear,
            radius: 10, y: 2
        )
    }

    /// Maquette miniature : bandeau, ligne de jeu et rangée d'accents,
    /// pour juger le thème sur les éléments réels de l'app.
    private var mockup: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xSmall + 2) {
            // Bandeau illustré.
            RoundedRectangle(cornerRadius: Theme.Radius.small, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [preview.accent.opacity(0.55), preview.glow.opacity(0.4)],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                )
                .frame(height: 18)

            // Ligne de jeu : jaquette, deux lignes de texte, pastille de note.
            HStack(spacing: 6) {
                RoundedRectangle(cornerRadius: 3, style: .continuous)
                    .fill(preview.accentAlt.opacity(0.75))
                    .frame(width: 18, height: 24)

                VStack(alignment: .leading, spacing: 3) {
                    bar(width: 42, opacity: 0.75)
                    bar(width: 26, opacity: 0.4)
                }

                Spacer(minLength: 0)

                Text("92")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(preview.tier(for: 92))
                    .padding(.horizontal, 5)
                    .padding(.vertical, 2)
                    .background(Capsule().fill(preview.tier(for: 92).opacity(0.18)))
            }
            .padding(6)
            .background(
                RoundedRectangle(cornerRadius: Theme.Radius.small, style: .continuous)
                    .fill(preview.surface.opacity(0.85))
            )

            // Palette d'accents des wikis.
            HStack(spacing: 5) {
                ForEach(Array(preview.pageAccents.prefix(4).enumerated()), id: \.offset) { _, color in
                    Circle().fill(color).frame(width: 9, height: 9)
                }
                Spacer(minLength: 0)
            }
        }
        .padding(Theme.Spacing.small)
    }

    private func bar(width: CGFloat, opacity: Double) -> some View {
        Capsule()
            .fill(preview.primaryText.opacity(opacity))
            .frame(width: width, height: 4)
    }

    // MARK: États

    private var selectionBorder: some View {
        RoundedRectangle(cornerRadius: Theme.Radius.medium, style: .continuous)
            .stroke(
                isSelected ? currentTheme.accent : .white.opacity(0.08),
                lineWidth: isSelected ? 2 : 1
            )
    }

    /// Voile léger + badge en coin : le verrou ne doit pas masquer l'aperçu,
    /// c'est justement lui qui donne envie de débloquer le thème.
    private var lockOverlay: some View {
        Color.black.opacity(0.22)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.medium, style: .continuous))
            .overlay(alignment: .topTrailing) {
                HStack(spacing: 3) {
                    Image(systemName: "lock.fill")
                    Text(localization.string(.profileThemePremium))
                }
                .font(.system(size: Theme.FontSize.caption - 3, weight: .bold))
                .foregroundStyle(.white)
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(Capsule().fill(.black.opacity(0.6)))
                .padding(6)
            }
    }
}

#Preview {
    HStack(alignment: .top, spacing: Theme.Spacing.medium) {
        ThemeSwatchView(themeID: .grymBlue, isSelected: true, isLocked: false)
        ThemeSwatchView(themeID: .grymEmerald, isSelected: false, isLocked: true)
    }
    .padding()
    .background(Color.grymBlueBgDark)
    .environmentObject(LocalizationManager())
    .environment(\.theme, GrymBlueTheme())
}
