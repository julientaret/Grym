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

    var body: some View {
        Menu {
            // Picker inline : coche de sélection native, plus lisible qu'une
            // liste de boutons avec une coche ajoutée à la main.
            Picker(selection: selection) {
                ForEach(GameStatus.allCases) { option in
                    Label(localization.string(option.nameKey), systemImage: option.systemImage)
                        .tag(option)
                }
            } label: {
                EmptyView()
            }
            .pickerStyle(.inline)
        } label: {
            label
        }
        .accessibilityLabel(localization.string(.statusLabel))
        .accessibilityValue(localization.string(status.nameKey))
    }

    private var selection: Binding<GameStatus> {
        Binding(get: { status }, set: onSelect)
    }

    // MARK: Pastille cliquable

    /// La pastille est dimensionnée sur le libellé le plus long : sans cela,
    /// le changement de statut fait varier sa largeur et l'en-tête se relayoute
    /// pendant la fermeture du menu (effet de « saut »).
    private var label: some View {
        ZStack {
            ForEach(GameStatus.allCases) { option in
                content(for: option).hidden()
            }
            content(for: status)
        }
        .padding(.horizontal, Theme.Spacing.small + 2)
        .padding(.vertical, Theme.Spacing.xSmall + 2)
        .background(
            Capsule().fill(status.color.opacity(0.16))
        )
        .overlay(
            Capsule().stroke(status.color.opacity(0.45), lineWidth: 1)
        )
        .contentShape(Capsule())
        .animation(.easeInOut(duration: Theme.AnimationDuration.fast), value: status)
    }

    private func content(for option: GameStatus) -> some View {
        HStack(spacing: Theme.Spacing.xSmall) {
            Image(systemName: option.systemImage)
                .font(.system(size: Theme.FontSize.caption - 1, weight: .bold))
                .frame(width: Theme.FontSize.caption + 2)
            Text(localization.string(option.nameKey))
                .font(.system(size: Theme.FontSize.caption, weight: .semibold))
                .lineLimit(1)
                .fixedSize()
            Image(systemName: "chevron.up.chevron.down")
                .font(.system(size: Theme.FontSize.caption - 3, weight: .bold))
                .opacity(0.7)
        }
        .foregroundStyle(option.color)
        .contentTransition(.identity)
    }
}

#Preview("Dark") {
    statusMenuPreview
        .background(Color.grymBgDark)
        .preferredColorScheme(.dark)
}

#Preview("Light") {
    statusMenuPreview
        .background(Color.grymBgLight)
        .preferredColorScheme(.light)
}

private var statusMenuPreview: some View {
    VStack(alignment: .leading, spacing: Theme.Spacing.small) {
        ForEach(GameStatus.allCases) { status in
            WikiStatusMenu(status: status, onSelect: { _ in })
        }
    }
    .padding()
    .environmentObject(LocalizationManager())
    .environment(\.theme, GrymBlueTheme())
}
