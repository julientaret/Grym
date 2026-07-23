//
//  PageEditorHeader.swift
//  Grym
//
//  En-tête de l'éditeur d'un wiki : titre éditable et ligne de contexte
//  (jeu d'appartenance, nombre de blocs). Sépare le titre du flux de blocs.
//

import SwiftUI

struct PageEditorHeader: View {
    @Binding var title: String
    /// Titre du jeu auquel appartient ce wiki, affiché en surtitre.
    var gameTitle: String?
    let blockCount: Int
    var titleFocus: FocusState<Bool>.Binding

    @EnvironmentObject private var localization: LocalizationManager
    @Environment(\.theme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.small) {
            if let gameTitle, !gameTitle.isEmpty {
                Text(gameTitle.uppercased())
                    .font(.system(size: Theme.FontSize.caption - 1, weight: .bold))
                    .tracking(Theme.Tracking.hud)
                    .foregroundStyle(theme.accent)
                    .lineLimit(1)
            }

            TextField(localization.string(.pageTitlePlaceholder), text: $title)
                .font(.system(size: Theme.FontSize.title + 4, weight: .bold))
                .foregroundStyle(theme.primaryText)
                .focused(titleFocus)
                .submitLabel(.done)

            HStack(spacing: Theme.Spacing.xSmall) {
                Image(systemName: "square.stack.3d.up")
                Text("\(blockCount) \(localization.string(.statBlocks))")
            }
            .font(.system(size: Theme.FontSize.caption, weight: .medium))
            .foregroundStyle(theme.secondaryText)

            Rectangle()
                .fill(theme.accent.opacity(0.25))
                .frame(height: 1)
                .padding(.top, Theme.Spacing.xSmall)
        }
    }
}

#Preview {
    @Previewable @State var title = "Boss & Remembrances"
    @Previewable @FocusState var focused: Bool

    return PageEditorHeader(
        title: $title,
        gameTitle: "Elden Ring",
        blockCount: 7,
        titleFocus: $focused
    )
    .padding()
    .background(Color.grymBgDark)
    .environmentObject(LocalizationManager())
    .environment(\.theme, GrymBlueTheme())
}
