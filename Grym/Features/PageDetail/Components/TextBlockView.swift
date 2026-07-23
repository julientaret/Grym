//
//  TextBlockView.swift
//  Grym
//
//  Bloc de texte libre, éditable en ligne. Le contenu est lié
//  directement à `Block.content`. Hors édition, les liens `[[Titre]]`
//  sont rendus cliquables et remontés via `onOpenLink`.
//

import SwiftData
import SwiftUI

struct TextBlockView: View {
    @Bindable var block: Block
    /// Wiki courant : sert à savoir si la page ciblée par un lien existe.
    var wiki: Wiki?
    /// Titre de page demandé par un lien touché.
    var onOpenLink: (String) -> Void = { _ in }
    /// Bloc tout juste créé : son nom prend le focus à l'apparition.
    var autofocusTitle: Bool = false
    var onTitleFocused: () -> Void = {}
    var actions: BlockActions?

    @EnvironmentObject private var localization: LocalizationManager
    @Environment(\.theme) private var theme

    @FocusState private var isFocused: Bool
    @State private var showingLinkPicker = false

    var body: some View {
        BlockCardView(
            type: .text,
            title: $block.title,
            autofocusTitle: autofocusTitle,
            onTitleFocused: onTitleFocused,
            actions: actions,
            accessory: { headerActions },
            content: { editor }
        )
        .environment(\.openURL, OpenURLAction { url in
            guard let title = WikiLink.title(from: url) else { return .systemAction }
            onOpenLink(title)
            return .handled
        })
        .sheet(isPresented: $showingLinkPicker) {
            PageLinkPickerView(pages: linkablePages) { title in
                appendLink(to: title)
            }
        }
    }

    // MARK: Zone d'édition

    private var editor: some View {
        ZStack(alignment: .topLeading) {
            TextField(
                localization.string(.textBlockPlaceholder),
                text: $block.content,
                axis: .vertical
            )
            .focused($isFocused)
            // Le champ reste dans la hiérarchie pour que le focus reste
            // possible ; il s'efface visuellement derrière le texte rendu.
            .opacity(showsRenderedText ? 0 : 1)

            // Aucun geste sur ce texte : les taps doivent atteindre les liens.
            // L'édition se reprend via le bouton crayon du bandeau.
            if showsRenderedText {
                Text(renderedText)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .font(.system(size: Theme.FontSize.body))
        .foregroundStyle(theme.primaryText)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: Actions du bandeau

    /// En édition : insertion de lien. Hors édition avec liens rendus :
    /// reprise de l'édition (le texte rendu n'accepte pas le focus).
    @ViewBuilder
    private var headerActions: some View {
        if isFocused {
            BlockHeaderButton(
                systemImage: "link",
                label: localization.string(.textBlockInsertLink)
            ) {
                showingLinkPicker = true
            }
        } else if showsRenderedText {
            BlockHeaderButton(
                systemImage: "pencil",
                label: localization.string(.commonEdit)
            ) {
                isFocused = true
            }
        }
    }

    // MARK: Rendu

    /// Le texte rendu ne remplace le champ que hors édition et s'il y a un lien.
    private var showsRenderedText: Bool {
        !isFocused && WikiLink.containsLink(block.content)
    }

    private var renderedText: AttributedString {
        WikiLink.attributed(
            block.content,
            resolve: { wiki?.page(titled: $0) != nil },
            linkColor: theme.accent,
            brokenColor: theme.secondaryText
        )
    }

    // MARK: Insertion d'un lien

    /// Pages du wiki hors celle qui contient ce bloc.
    private var linkablePages: [Page] {
        guard let wiki else { return [] }
        return wiki.pages
            .filter { $0.persistentModelID != block.page?.persistentModelID }
            .sorted { $0.order < $1.order }
    }

    private func appendLink(to title: String) {
        let separator = block.content.isEmpty || block.content.hasSuffix(" ") ? "" : " "
        block.content += separator + WikiLink.markup(for: title)
    }
}

#Preview {
    TextBlockView(block: Block(
        type: .text,
        content: "Voir [[Builds]] avant d'affronter Malenia.",
        order: 0
    ))
    .padding()
    .background(Color.grymBgDark)
    .environmentObject(LocalizationManager())
    .environment(\.theme, GrymBlueTheme())
}
