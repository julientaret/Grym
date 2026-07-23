//
//  BlockPaletteView.swift
//  Grym
//
//  Palette d'ajout de blocs : un bouton par type, ajout en un seul tap.
//  Remplace l'ancien menu déroulant, qui masquait les types disponibles
//  derrière une interaction supplémentaire.
//

import SwiftUI

struct BlockPaletteView: View {
    let onAdd: (BlockType) -> Void

    @EnvironmentObject private var localization: LocalizationManager
    @Environment(\.theme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.small) {
            Text(localization.string(.addBlock).uppercased())
                .font(.system(size: Theme.FontSize.caption - 1, weight: .bold))
                .tracking(Theme.Tracking.hud)
                .foregroundStyle(theme.secondaryText)

            HStack(spacing: Theme.Spacing.small) {
                ForEach(BlockType.allCases, id: \.self) { type in
                    button(for: type)
                }
            }
        }
        .padding(Theme.Spacing.medium)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: Theme.Radius.large, style: .continuous)
                .strokeBorder(
                    theme.secondaryText.opacity(0.25),
                    style: StrokeStyle(lineWidth: 1, dash: [4, 4])
                )
        )
    }

    private func button(for type: BlockType) -> some View {
        let accent = type.accent(in: theme)
        return Button {
            onAdd(type)
        } label: {
            VStack(spacing: Theme.Spacing.xSmall + 2) {
                Image(systemName: type.systemImage)
                    .font(.system(size: Theme.FontSize.body, weight: .semibold))
                    .foregroundStyle(accent)

                Text(localization.string(type.nameKey))
                    .font(.system(size: Theme.FontSize.caption - 1, weight: .semibold))
                    .foregroundStyle(theme.primaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, Theme.Spacing.small + 2)
            .background(
                RoundedRectangle(cornerRadius: Theme.Radius.medium, style: .continuous)
                    .fill(accent.opacity(0.12))
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    BlockPaletteView { _ in }
        .padding()
        .background(Color.grymBgDark)
        .environmentObject(LocalizationManager())
        .environment(\.theme, GrymBlueTheme())
}
