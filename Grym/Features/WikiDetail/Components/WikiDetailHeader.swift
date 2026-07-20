//
//  WikiDetailHeader.swift
//  Grym
//
//  En-tête du détail d'un wiki : cover, titre, méta, bouton d'épinglage
//  et ligne de statistiques (blocs / photos / listes · mise à jour).
//

import SwiftUI

struct WikiDetailHeader: View {
    let title: String
    let coverImageId: String?
    let coverTint: Color
    let metaLine: String?
    let blockCount: Int
    let photoCount: Int
    let listCount: Int
    let updatedAt: Date
    let isPinned: Bool
    let onTogglePin: () -> Void

    @EnvironmentObject private var localization: LocalizationManager
    @Environment(\.theme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.medium) {
            HStack(alignment: .top, spacing: Theme.Spacing.medium) {
                WikiCoverView(imageId: coverImageId, tint: coverTint,
                              cornerRadius: Theme.Radius.medium)
                    .frame(width: 96, height: 128)

                VStack(alignment: .leading, spacing: Theme.Spacing.xSmall) {
                    Text(title)
                        .font(.system(size: Theme.FontSize.title, weight: .bold))
                        .foregroundStyle(theme.primaryText)
                        .fixedSize(horizontal: false, vertical: true)

                    if let metaLine {
                        Text(metaLine)
                            .font(.system(size: Theme.FontSize.caption, weight: .regular))
                            .foregroundStyle(theme.secondaryText)
                    }

                    Spacer(minLength: 0)

                    pinButton
                }

                Spacer(minLength: 0)
            }

            statsRow
        }
    }

    // MARK: Bouton épingler

    private var pinButton: some View {
        Button(action: onTogglePin) {
            HStack(spacing: Theme.Spacing.xSmall) {
                Image(systemName: isPinned ? "pin.fill" : "pin")
                Text(localization.string(isPinned ? .wikiUnpin : .wikiPin))
                    .font(.system(size: Theme.FontSize.caption, weight: .semibold))
            }
            .foregroundStyle(isPinned ? theme.accent : theme.secondaryText)
            .padding(.horizontal, Theme.Spacing.small + 2)
            .padding(.vertical, Theme.Spacing.xSmall + 2)
            .background(
                Capsule().fill(isPinned ? theme.accent.opacity(0.15) : theme.surface.opacity(0.6))
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: Statistiques

    private var statsRow: some View {
        HStack(spacing: Theme.Spacing.medium) {
            stat(blockCount, localization.string(.statBlocks), theme.accent)
            stat(photoCount, localization.string(.statPhotos), theme.accentAlt)
            stat(listCount, localization.string(.statLists), theme.brand)

            Spacer(minLength: Theme.Spacing.small)

            HStack(spacing: Theme.Spacing.xSmall) {
                Image(systemName: "clock")
                Text(updatedAt.relativeDescription)
            }
            .font(.system(size: Theme.FontSize.caption, weight: .regular))
            .foregroundStyle(theme.secondaryText)
        }
        .padding(Theme.Spacing.medium)
        .background(
            RoundedRectangle(cornerRadius: Theme.Radius.medium, style: .continuous)
                .fill(theme.surface.opacity(0.4))
        )
    }

    private func stat(_ count: Int, _ label: String, _ color: Color) -> some View {
        HStack(spacing: Theme.Spacing.xSmall) {
            Circle().fill(color).frame(width: 6, height: 6)
            Text("\(count)")
                .font(.system(size: Theme.FontSize.caption, weight: .semibold))
                .foregroundStyle(theme.primaryText)
            Text(label)
                .font(.system(size: Theme.FontSize.caption, weight: .regular))
                .foregroundStyle(theme.secondaryText)
        }
    }
}

#Preview {
    WikiDetailHeader(
        title: "Subnautica", coverImageId: nil, coverTint: Color(hex: 0x2FA9D8),
        metaLine: "2018 · PC", blockCount: 47, photoCount: 24, listCount: 5,
        updatedAt: Date().addingTimeInterval(-259_200), isPinned: true, onTogglePin: {}
    )
    .padding()
    .background(Color.grymBgDark)
    .environmentObject(LocalizationManager())
    .environment(\.theme, GrymBlueTheme())
}
