//
//  GameSortMenu.swift
//  Grym
//
//  Menu de choix du critère de tri de la liste « Mes jeux ».
//

import SwiftUI

struct GameSortMenu: View {
    @Binding var selection: GameSortOption

    @EnvironmentObject private var localization: LocalizationManager
    @Environment(\.theme) private var theme

    var body: some View {
        Menu {
            Picker(localization.string(.sortLabel), selection: $selection) {
                ForEach(GameSortOption.allCases) { option in
                    Label(localization.string(option.nameKey),
                          systemImage: option.systemImage)
                        .tag(option)
                }
            }
        } label: {
            HStack(spacing: Theme.Spacing.xSmall + 2) {
                Image(systemName: "arrow.up.arrow.down")
                Text(localization.string(selection.nameKey))
            }
            .font(.system(size: Theme.FontSize.caption, weight: .semibold))
            .foregroundStyle(theme.secondaryText)
            .padding(.horizontal, Theme.Spacing.medium)
            .padding(.vertical, Theme.Spacing.small)
            .background(Capsule().fill(theme.surface))
        }
        .accessibilityLabel(localization.string(.sortLabel))
    }
}

#Preview {
    @Previewable @State var selection: GameSortOption = .title

    return GameSortMenu(selection: $selection)
        .padding()
        .background(Color.grymBgDark)
        .environmentObject(LocalizationManager())
        .environment(\.theme, GrymBlueTheme())
}
