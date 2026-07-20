//
//  EmptyBlocksPlaceholder.swift
//  Grym
//
//  Placeholder affiché dans un wiki sans bloc : présente chaque type de bloc
//  disponible (icône, nom, rôle) pour guider la première création.
//

import SwiftUI

struct EmptyBlocksPlaceholder: View {
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
            ForEach(Array(BlockType.allCases.enumerated()), id: \.element) { index, type in
                card(for: type, accent: accent(at: index))
            }
        }
    }

    private func card(for type: BlockType, accent: Color) -> some View {
        HStack(spacing: Theme.Spacing.medium) {
            Image(systemName: type.systemImage)
                .font(.system(size: Theme.FontSize.body, weight: .semibold))
                .foregroundStyle(accent)
                .frame(width: 36, height: 36)
                .background(
                    RoundedRectangle(cornerRadius: Theme.Radius.small, style: .continuous)
                        .fill(accent.opacity(0.15))
                )

            VStack(alignment: .leading, spacing: Theme.Spacing.xSmall / 2) {
                Text(localization.string(title(for: type)))
                    .font(.system(size: Theme.FontSize.body - 1, weight: .semibold))
                    .foregroundStyle(theme.primaryText)

                Text(localization.string(hint(for: type)))
                    .font(.system(size: Theme.FontSize.caption))
                    .foregroundStyle(theme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(Theme.Spacing.medium)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: Theme.Radius.large, style: .continuous)
                .fill(theme.surface.opacity(0.45))
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.Radius.large, style: .continuous)
                        .stroke(.white.opacity(0.06), lineWidth: 1)
                )
        )
    }

    private func accent(at index: Int) -> Color {
        let accents = theme.pageAccents
        return accents[index % accents.count]
    }

    private func title(for type: BlockType) -> TranslationKey {
        switch type {
        case .text:      .blockTypeText
        case .photo:     .blockTypePhoto
        case .checklist: .blockTypeChecklist
        case .map:       .blockTypeMap
        }
    }

    private func hint(for type: BlockType) -> TranslationKey {
        switch type {
        case .text:      .blockTypeTextHint
        case .photo:     .blockTypePhotoHint
        case .checklist: .blockTypeChecklistHint
        case .map:       .blockTypeMapHint
        }
    }
}

#Preview {
    ScrollView {
        EmptyBlocksPlaceholder()
            .padding(.horizontal, Theme.Spacing.medium)
    }
    .background(Color.grymBgDark)
    .environmentObject(LocalizationManager())
    .environment(\.theme, GrymBlueTheme())
}
