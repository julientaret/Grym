//
//  GameStatusBadge.swift
//  Grym
//
//  Pastille de statut de progression, réutilisée par le détail d'un wiki
//  et par les lignes de « Mes jeux ».
//

import SwiftUI

struct GameStatusBadge: View {
    let status: GameStatus
    /// Variante compacte : icône seule, pour les listes denses.
    var compact: Bool = false

    @EnvironmentObject private var localization: LocalizationManager

    var body: some View {
        HStack(spacing: Theme.Spacing.xSmall) {
            Image(systemName: status.systemImage)
                .font(.system(size: Theme.FontSize.caption - 1, weight: .bold))
            if !compact {
                Text(localization.string(status.nameKey))
                    .font(.system(size: Theme.FontSize.caption, weight: .semibold))
            }
        }
        .foregroundStyle(status.color)
        .padding(.horizontal, compact ? Theme.Spacing.xSmall + 2 : Theme.Spacing.small)
        .padding(.vertical, Theme.Spacing.xSmall)
        .background(
            Capsule().fill(status.color.opacity(0.15))
        )
        .overlay(
            Capsule().stroke(status.color.opacity(0.35), lineWidth: 1)
        )
    }
}

#Preview {
    VStack(alignment: .leading, spacing: Theme.Spacing.small) {
        ForEach(GameStatus.assignable) { status in
            GameStatusBadge(status: status)
        }
        GameStatusBadge(status: .playing, compact: true)
    }
    .padding()
    .background(Color.grymBgDark)
    .environmentObject(LocalizationManager())
}
