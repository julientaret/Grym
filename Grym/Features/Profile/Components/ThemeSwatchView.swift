//
//  ThemeSwatchView.swift
//  Grym
//
//  Vignette d'un thème : aperçu du fond dégradé, du halo et des accents,
//  nom, état sélectionné et badge premium si le thème est verrouillé.
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

            HStack(spacing: Theme.Spacing.xSmall) {
                Text(localization.string(themeID.nameKey))
                    .font(.system(size: Theme.FontSize.caption + 1, weight: .semibold))
                    .foregroundStyle(currentTheme.primaryText)

                Spacer(minLength: 0)

                if isLocked {
                    Image(systemName: "lock.fill")
                        .font(.system(size: Theme.FontSize.caption - 1, weight: .semibold))
                        .foregroundStyle(currentTheme.secondaryText)
                } else if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: Theme.FontSize.caption + 1, weight: .semibold))
                        .foregroundStyle(currentTheme.accent)
                }
            }
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
                colors: [preview.glow.opacity(0.75), .clear],
                center: UnitPoint(x: 0.5, y: 0.05),
                startRadius: 2,
                endRadius: 78
            )

            // Surface de carte + pastilles d'accent, comme dans l'app.
            VStack(alignment: .leading, spacing: Theme.Spacing.small) {
                Spacer(minLength: 0)

                HStack(spacing: 6) {
                    ForEach(Array(preview.pageAccents.prefix(3).enumerated()), id: \.offset) { _, color in
                        Circle()
                            .fill(color)
                            .frame(width: 12, height: 12)
                    }
                    Spacer(minLength: 0)
                }

                RoundedRectangle(cornerRadius: Theme.Radius.small, style: .continuous)
                    .fill(preview.surface.opacity(0.85))
                    .frame(height: 22)
                    .overlay(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(preview.accent)
                            .frame(width: 3)
                            .padding(.vertical, 5)
                            .padding(.leading, 1)
                    }
            }
            .padding(Theme.Spacing.small)
        }
        .frame(height: 96)
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.medium, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.Radius.medium, style: .continuous)
                .stroke(
                    isSelected ? currentTheme.accent : .white.opacity(0.08),
                    lineWidth: isSelected ? 2 : 1
                )
        )
        .overlay(alignment: .topTrailing) {
            if isLocked {
                Text(localization.string(.profileThemePremium))
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(Capsule().fill(.black.opacity(0.45)))
                    .padding(6)
            }
        }
        .opacity(isLocked ? 0.75 : 1)
    }
}

#Preview {
    HStack(spacing: Theme.Spacing.medium) {
        ThemeSwatchView(themeID: .grymBlue, isSelected: true, isLocked: false)
        ThemeSwatchView(themeID: .grymEmerald, isSelected: false, isLocked: true)
    }
    .padding()
    .background(Color.grymBlueBgDark)
    .environmentObject(LocalizationManager())
    .environment(\.theme, GrymBlueTheme())
}
