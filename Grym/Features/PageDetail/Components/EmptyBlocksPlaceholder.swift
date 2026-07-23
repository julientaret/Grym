//
//  EmptyBlocksPlaceholder.swift
//  Grym
//
//  Placeholder affiché dans un wiki sans bloc : chaque type de bloc y est
//  présenté (icône, nom, rôle) et se crée directement au tap.
//

import SwiftUI

struct EmptyBlocksPlaceholder: View {
    /// Création du bloc choisi : la carte est un vrai point d'entrée,
    /// pas une simple explication.
    let onAdd: (BlockType) -> Void

    @EnvironmentObject private var localization: LocalizationManager
    @Environment(\.theme) private var theme

    var body: some View {
        VStack(spacing: Theme.Spacing.large) {
            header
            cards
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Theme.Spacing.large)
    }

    // MARK: En-tête

    private var header: some View {
        VStack(spacing: Theme.Spacing.small) {
            Image(systemName: "square.stack.3d.up")
                .font(.system(size: Theme.FontSize.largeTitle, weight: .light))
                .foregroundStyle(
                    LinearGradient(
                        colors: [theme.accent, theme.accentAlt],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            Text(localization.string(.pageEmptyTitle))
                .font(.system(size: Theme.FontSize.title, weight: .bold))
                .foregroundStyle(theme.primaryText)

            Text(localization.string(.pageEmptyBlocks))
                .font(.system(size: Theme.FontSize.caption + 1))
                .foregroundStyle(theme.secondaryText)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    // MARK: Cartes des types de blocs

    private var cards: some View {
        VStack(spacing: Theme.Spacing.small) {
            ForEach(BlockType.allCases, id: \.self) { type in
                Button { onAdd(type) } label: { card(for: type) }
                    .buttonStyle(.plain)
            }
        }
    }

    private func card(for type: BlockType) -> some View {
        let accent = type.accent(in: theme)
        return HStack(spacing: Theme.Spacing.medium) {
            Image(systemName: type.systemImage)
                .font(.system(size: Theme.FontSize.body, weight: .semibold))
                .foregroundStyle(accent)
                .frame(width: Theme.Size.blockTypeTile, height: Theme.Size.blockTypeTile)
                .background(
                    RoundedRectangle(cornerRadius: Theme.Radius.small, style: .continuous)
                        .fill(accent.opacity(0.15))
                )

            VStack(alignment: .leading, spacing: Theme.Spacing.xSmall / 2) {
                Text(localization.string(type.nameKey))
                    .font(.system(size: Theme.FontSize.body - 1, weight: .semibold))
                    .foregroundStyle(theme.primaryText)

                Text(localization.string(type.hintKey))
                    .font(.system(size: Theme.FontSize.caption))
                    .foregroundStyle(theme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)
            }

            Spacer(minLength: 0)

            Image(systemName: "plus.circle.fill")
                .font(.system(size: Theme.FontSize.body))
                .foregroundStyle(accent)
        }
        .padding(Theme.Spacing.medium)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: Theme.Radius.large, style: .continuous)
                .fill(theme.surface.opacity(0.45))
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.Radius.large, style: .continuous)
                        .stroke(accent.opacity(0.18), lineWidth: 1)
                )
        )
    }
}

#Preview {
    ScrollView {
        EmptyBlocksPlaceholder { _ in }
            .padding(.horizontal, Theme.Spacing.medium)
    }
    .background(Color.grymBgDark)
    .environmentObject(LocalizationManager())
    .environment(\.theme, GrymBlueTheme())
}
