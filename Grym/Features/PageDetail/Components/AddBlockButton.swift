//
//  AddBlockButton.swift
//  Grym
//
//  Bouton pleine largeur avec menu de choix du type de bloc à ajouter.
//

import SwiftUI

struct AddBlockButton: View {
    let onAdd: (BlockType) -> Void

    @EnvironmentObject private var localization: LocalizationManager
    @Environment(\.theme) private var theme

    var body: some View {
        Menu {
            Button {
                onAdd(.text)
            } label: {
                Label(localization.string(.blockTypeText), systemImage: "text.alignleft")
            }
            Button {
                onAdd(.checklist)
            } label: {
                Label(localization.string(.blockTypeChecklist), systemImage: "checklist")
            }
            Button {
                onAdd(.photo)
            } label: {
                Label(localization.string(.blockTypePhoto), systemImage: "photo")
            }
            Button {
                onAdd(.map)
            } label: {
                Label(localization.string(.blockTypeMap), systemImage: "map")
            }
        } label: {
            HStack(spacing: Theme.Spacing.small) {
                Image(systemName: "plus")
                Text(localization.string(.addBlock))
            }
            .font(.system(size: Theme.FontSize.body, weight: .semibold))
            .foregroundStyle(theme.accent)
            .frame(maxWidth: .infinity)
            .padding(.vertical, Theme.Spacing.medium)
            .background(
                RoundedRectangle(cornerRadius: Theme.Radius.medium, style: .continuous)
                    .strokeBorder(theme.accent.opacity(0.4), style: StrokeStyle(lineWidth: 1, dash: [5]))
            )
        }
    }
}

#Preview {
    AddBlockButton { _ in }
        .padding()
        .background(Color.grymBgDark)
        .environmentObject(LocalizationManager())
        .environment(\.theme, GrymBlueTheme())
}
