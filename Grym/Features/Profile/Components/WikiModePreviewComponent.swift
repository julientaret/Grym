//
//  WikiModePreviewComponent.swift
//  Grym
//
//  Aperçu miniature du mode d'affichage choisi, avec deux wikis factices.
//  Rendu schématique (pas les vrais composants) pour rester léger et lisible
//  dans une carte de réglage.
//

import SwiftUI

struct WikiModePreviewComponent: View {
    let mode: WikiPagesMode

    @EnvironmentObject private var localization: LocalizationManager
    @Environment(\.theme) private var theme

    /// Wikis factices : titre + accent, repris de la palette du thème actif
    /// pour que l'aperçu suive le thème choisi juste au-dessus.
    private var samples: [(title: String, accent: Color)] {
        let accents = theme.pageAccents
        return [
            (localization.string(.profileWikiModeSampleFirst), accents[0]),
            (localization.string(.profileWikiModeSampleSecond), accents[min(1, accents.count - 1)])
        ]
    }

    var body: some View {
        Group {
            switch mode {
            case .list:  listPreview
            case .tabs:  tabsPreview
            case .cards: cardsPreview
            }
        }
        .padding(Theme.Spacing.medium)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: Theme.Radius.medium, style: .continuous)
                .fill(theme.backgroundDeep.opacity(0.6))
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.Radius.medium, style: .continuous)
                        .stroke(.white.opacity(0.05), lineWidth: 1)
                )
        )
        .animation(.easeInOut(duration: Theme.AnimationDuration.fast), value: mode)
    }

    // MARK: Modes

    private var listPreview: some View {
        VStack(spacing: Theme.Spacing.small) {
            ForEach(samples, id: \.title) { sample in
                HStack(spacing: Theme.Spacing.small) {
                    thumbnail(sample.accent, size: 24)

                    VStack(alignment: .leading, spacing: 3) {
                        Text(sample.title)
                            .font(.system(size: Theme.FontSize.caption, weight: .semibold))
                            .foregroundStyle(theme.primaryText)
                        skeletonBar(width: 54)
                    }

                    Spacer(minLength: 0)

                    Image(systemName: "chevron.right")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundStyle(theme.secondaryText)
                }
                .padding(Theme.Spacing.small)
                .background(
                    RoundedRectangle(cornerRadius: Theme.Radius.small, style: .continuous)
                        .fill(theme.surface.opacity(0.45))
                        .overlay(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(sample.accent)
                                .frame(width: 3)
                                .padding(.vertical, 6)
                        }
                )
            }
        }
    }

    private var tabsPreview: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.small) {
            HStack(spacing: Theme.Spacing.small) {
                ForEach(Array(samples.enumerated()), id: \.element.title) { index, sample in
                    Text(sample.title)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(index == 0 ? .white : theme.secondaryText)
                        .padding(.horizontal, Theme.Spacing.small + 2)
                        .padding(.vertical, 5)
                        .background(
                            Capsule().fill(index == 0 ? theme.accent : theme.surface.opacity(0.5))
                        )
                }
            }

            VStack(alignment: .leading, spacing: 6) {
                skeletonBar(width: 92)
                skeletonBar(width: 64)
                skeletonBar(width: 78)
            }
            .padding(Theme.Spacing.small)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: Theme.Radius.small, style: .continuous)
                    .fill(theme.surface.opacity(0.45))
            )
        }
    }

    private var cardsPreview: some View {
        HStack(spacing: Theme.Spacing.small) {
            ForEach(samples, id: \.title) { sample in
                VStack(alignment: .leading, spacing: 6) {
                    thumbnail(sample.accent, size: 22)
                    Text(sample.title)
                        .font(.system(size: Theme.FontSize.caption, weight: .semibold))
                        .foregroundStyle(theme.primaryText)
                        .lineLimit(1)
                    skeletonBar(width: 40)
                }
                .padding(Theme.Spacing.small)
                .frame(maxWidth: .infinity, alignment: .topLeading)
                .background(
                    RoundedRectangle(cornerRadius: Theme.Radius.small, style: .continuous)
                        .fill(theme.surface.opacity(0.45))
                        .overlay(alignment: .top) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(sample.accent)
                                .frame(height: 3)
                                .padding(.horizontal, Theme.Spacing.small)
                        }
                )
            }
        }
    }

    // MARK: Éléments schématiques

    private func thumbnail(_ accent: Color, size: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: Theme.Radius.small - 2, style: .continuous)
            .fill(accent.opacity(0.25))
            .frame(width: size, height: size)
            .overlay(
                Image(systemName: "doc.text")
                    .font(.system(size: size * 0.5, weight: .semibold))
                    .foregroundStyle(accent)
            )
    }

    /// Barre grise figurant une ligne de contenu.
    private func skeletonBar(width: CGFloat) -> some View {
        Capsule()
            .fill(theme.secondaryText.opacity(0.25))
            .frame(width: width, height: 4)
    }
}

#Preview {
    VStack(spacing: Theme.Spacing.medium) {
        ForEach(WikiPagesMode.allCases) { mode in
            WikiModePreviewComponent(mode: mode)
        }
    }
    .padding()
    .background(Color.grymBgDark)
    .environmentObject(LocalizationManager())
    .environment(\.theme, GrymBlueTheme())
}
