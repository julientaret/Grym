//
//  TextBlockView.swift
//  Grym
//
//  Bloc de texte libre, éditable en ligne. Le contenu est lié
//  directement à `Block.content`.
//

import SwiftUI

struct TextBlockView: View {
    @Bindable var block: Block

    @EnvironmentObject private var localization: LocalizationManager
    @Environment(\.theme) private var theme

    var body: some View {
        TextField(
            localization.string(.textBlockPlaceholder),
            text: $block.content,
            axis: .vertical
        )
        .font(.system(size: Theme.FontSize.body))
        .foregroundStyle(theme.primaryText)
        .padding(Theme.Spacing.medium)
        .background(
            RoundedRectangle(cornerRadius: Theme.Radius.medium, style: .continuous)
                .fill(theme.surface.opacity(0.4))
        )
    }
}

#Preview {
    TextBlockView(block: Block(type: .text, content: "Malenia, Blade of Miquella", order: 0))
        .padding()
        .background(Color.grymBgDark)
        .environmentObject(LocalizationManager())
        .environment(\.theme, GrymBlueTheme())
}
