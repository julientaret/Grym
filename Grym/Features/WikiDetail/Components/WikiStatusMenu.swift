//
//  WikiStatusMenu.swift
//  Grym
//
//  Sélecteur de statut de progression d'un wiki : pastille cliquable
//  ouvrant un menu des statuts disponibles.
//

import SwiftUI

struct WikiStatusMenu: View {
    let status: GameStatus
    var onSelect: (GameStatus) -> Void

    @EnvironmentObject private var localization: LocalizationManager
    @Environment(\.theme) private var theme

    var body: some View {
        Menu {
            ForEach(GameStatus.allCases) { option in
                Button {
                    onSelect(option)
                } label: {
                    Label(localization.string(option.nameKey), systemImage: option.systemImage)
                    if option == status { Image(systemName: "checkmark") }
                }
            }
        } label: {
            HStack(spacing: Theme.Spacing.xSmall) {
                GameStatusBadge(status: status)
                Image(systemName: "chevron.down")
                    .font(.system(size: Theme.FontSize.caption - 2, weight: .bold))
                    .foregroundStyle(theme.secondaryText)
            }
        }
    }
}

#Preview {
    WikiStatusMenu(status: .playing, onSelect: { _ in })
        .padding()
        .background(Color.grymBgDark)
        .environmentObject(LocalizationManager())
        .environment(\.theme, GrymBlueTheme())
}
