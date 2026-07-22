//
//  GameStatusFilterMenu.swift
//  Grym
//
//  Menu de filtrage de la liste « Mes jeux » par statut de progression.
//  `nil` = aucun filtre (tous les jeux).
//

import SwiftUI

struct GameStatusFilterMenu: View {
    @Binding var selection: GameStatus?

    @EnvironmentObject private var localization: LocalizationManager
    @Environment(\.theme) private var theme

    var body: some View {
        Menu {
            Button {
                selection = nil
            } label: {
                Label(localization.string(.statusFilterAll), systemImage: "square.grid.2x2")
            }
            ForEach(GameStatus.allCases) { status in
                Button {
                    selection = status
                } label: {
                    Label(localization.string(status.nameKey), systemImage: status.systemImage)
                }
            }
        } label: {
            HStack(spacing: Theme.Spacing.xSmall + 2) {
                Image(systemName: "line.3.horizontal.decrease")
                Text(label)
            }
            .font(.system(size: Theme.FontSize.caption, weight: .semibold))
            .foregroundStyle(selection == nil ? theme.secondaryText : theme.accent)
            .padding(.horizontal, Theme.Spacing.medium)
            .padding(.vertical, Theme.Spacing.small)
            .background(Capsule().fill(theme.surface))
        }
        .accessibilityLabel(localization.string(.filterLabel))
    }

    private var label: String {
        localization.string(selection?.nameKey ?? .statusFilterAll)
    }
}

#Preview {
    @Previewable @State var selection: GameStatus? = .playing

    return GameStatusFilterMenu(selection: $selection)
        .padding()
        .background(Color.grymBgDark)
        .environmentObject(LocalizationManager())
        .environment(\.theme, GrymBlueTheme())
}
