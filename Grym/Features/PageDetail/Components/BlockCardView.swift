//
//  BlockCardView.swift
//  Grym
//
//  Habillage commun à tous les blocs de l'éditeur : bandeau de type coloré,
//  actions du bloc (monter / descendre / supprimer) et zone de contenu.
//  Donne une identité visuelle à chaque type et rend les actions accessibles
//  sans passer par le mode édition global de la liste.
//

import SwiftUI

/// Actions structurelles proposées dans le menu d'un bloc.
struct BlockActions {
    var canMoveUp = false
    var canMoveDown = false
    var onMoveUp: () -> Void = {}
    var onMoveDown: () -> Void = {}
    var onDelete: () -> Void = {}
}

struct BlockCardView<Accessory: View, Content: View>: View {
    let type: BlockType
    /// Nom du bloc, éditable dans le bandeau. Vide, le nom du type sert
    /// de texte d'invite.
    @Binding var title: String
    /// Bloc tout juste créé : le nom prend le focus, première chose à saisir.
    var autofocusTitle: Bool = false
    /// Remonté dès la prise de focus, pour que l'appelant désarme l'autofocus.
    var onTitleFocused: () -> Void = {}
    /// Remonté une seule fois, quand l'utilisateur en a fini avec le nom
    /// d'un bloc tout juste créé (validation ou sortie du champ). Sert aux
    /// blocs qui enchaînent sur une action — photo et carte ouvrent leur
    /// sélecteur d'images à ce moment-là, pas avant.
    var onTitleSubmitted: () -> Void = {}
    /// Marges de la zone de contenu ; mises à zéro pour les blocs qui
    /// vont d'un bord à l'autre (photos, carte).
    var contentPadding: CGFloat = Theme.Spacing.medium
    var actions: BlockActions?
    @ViewBuilder var accessory: () -> Accessory
    @ViewBuilder var content: () -> Content

    @EnvironmentObject private var localization: LocalizationManager
    @Environment(\.theme) private var theme

    @FocusState private var isTitleFocused: Bool
    /// Vrai entre la prise de focus automatique et la sortie du champ :
    /// borne l'enchaînement à la seule création du bloc.
    @State private var isNamingNewBlock = false

    private var accent: Color { type.accent(in: theme) }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            content()
                .padding(contentPadding)
        }
        .background(
            RoundedRectangle(cornerRadius: Theme.Radius.large, style: .continuous)
                .fill(theme.surface.opacity(0.5))
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.Radius.large, style: .continuous)
                        .stroke(accent.opacity(0.18), lineWidth: 1)
                )
        )
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.large, style: .continuous))
        // Laisse la ligne s'insérer avant de réclamer le clavier : sans ce
        // délai, le focus est perdu pendant l'animation d'insertion de la List.
        .task {
            guard autofocusTitle else { return }
            try? await Task.sleep(for: .seconds(Theme.AnimationDuration.fast))
            onTitleFocused()
            isNamingNewBlock = true
            isTitleFocused = true
        }
        // Fin du nommage : validation au clavier ou tap ailleurs, même issue.
        .onChange(of: isTitleFocused) { wasFocused, isFocused in
            guard isNamingNewBlock, wasFocused, !isFocused else { return }
            isNamingNewBlock = false
            onTitleSubmitted()
        }
    }

    // MARK: Bandeau : icône de type + nom éditable

    private var header: some View {
        HStack(spacing: Theme.Spacing.small) {
            Image(systemName: type.systemImage)
                .font(.system(size: Theme.FontSize.caption, weight: .bold))
                .foregroundStyle(accent)
                .frame(width: Theme.Size.blockTypeBadge, height: Theme.Size.blockTypeBadge)
                .background(
                    RoundedRectangle(cornerRadius: Theme.Radius.small, style: .continuous)
                        .fill(accent.opacity(0.18))
                )
                .accessibilityLabel(localization.string(type.nameKey))

            TextField(localization.string(type.nameKey), text: $title)
                .font(.system(size: Theme.FontSize.body - 1, weight: .semibold))
                .foregroundStyle(theme.primaryText)
                .focused($isTitleFocused)
                .submitLabel(.done)
                // Rend la validation explicite : « OK » referme le champ, ce
                // qui déclenche l'enchaînement au même titre qu'un tap ailleurs.
                .onSubmit { isTitleFocused = false }
                .accessibilityLabel(localization.string(.blockName))

            accessory()

            if let actions {
                menu(actions)
            }
        }
        .padding(.horizontal, Theme.Spacing.medium)
        .padding(.vertical, Theme.Spacing.small + 2)
        .background(accent.opacity(0.07))
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(accent.opacity(0.15))
                .frame(height: 1)
        }
    }

    // MARK: Menu d'actions

    private func menu(_ actions: BlockActions) -> some View {
        Menu {
            Button {
                isTitleFocused = true
            } label: {
                Label(localization.string(.blockRename), systemImage: "pencil")
            }
            if actions.canMoveUp {
                Button(action: actions.onMoveUp) {
                    Label(localization.string(.blockMoveUp), systemImage: "arrow.up")
                }
            }
            if actions.canMoveDown {
                Button(action: actions.onMoveDown) {
                    Label(localization.string(.blockMoveDown), systemImage: "arrow.down")
                }
            }
            Divider()
            Button(role: .destructive, action: actions.onDelete) {
                Label(localization.string(.commonDelete), systemImage: "trash")
            }
        } label: {
            Image(systemName: "ellipsis")
                .font(.system(size: Theme.FontSize.caption, weight: .bold))
                .foregroundStyle(theme.secondaryText)
                .frame(width: Theme.Size.blockTypeBadge, height: Theme.Size.blockTypeBadge)
                .contentShape(Rectangle())
        }
        .accessibilityLabel(localization.string(.blockActions))
    }
}

// MARK: - Confort d'appel

extension BlockCardView where Accessory == EmptyView {
    init(
        type: BlockType,
        title: Binding<String>,
        autofocusTitle: Bool = false,
        onTitleFocused: @escaping () -> Void = {},
        onTitleSubmitted: @escaping () -> Void = {},
        contentPadding: CGFloat = Theme.Spacing.medium,
        actions: BlockActions? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.init(
            type: type,
            title: title,
            autofocusTitle: autofocusTitle,
            onTitleFocused: onTitleFocused,
            onTitleSubmitted: onTitleSubmitted,
            contentPadding: contentPadding,
            actions: actions,
            accessory: { EmptyView() },
            content: content
        )
    }
}

/// Petit bouton d'action posé dans le bandeau d'un bloc.
struct BlockHeaderButton: View {
    let systemImage: String
    let label: String
    let action: () -> Void

    @Environment(\.theme) private var theme

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: Theme.FontSize.caption, weight: .bold))
                .foregroundStyle(theme.accent)
                .frame(width: Theme.Size.blockTypeBadge, height: Theme.Size.blockTypeBadge)
                .background(
                    RoundedRectangle(cornerRadius: Theme.Radius.small, style: .continuous)
                        .fill(theme.accent.opacity(0.14))
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
    }
}

#Preview {
    @Previewable @State var named = "Stratégie Malenia"
    @Previewable @State var unnamed = ""

    return VStack(spacing: Theme.Spacing.medium) {
        BlockCardView(type: .text, title: $named, actions: BlockActions(canMoveDown: true)) {
            Text("Voir Builds avant d'affronter Malenia.")
                .frame(maxWidth: .infinity, alignment: .leading)
        }

        // Bloc sans nom : le type sert de texte d'invite.
        BlockCardView(
            type: .checklist,
            title: $unnamed,
            actions: BlockActions(canMoveUp: true),
            accessory: { Text("2/5").font(.system(size: Theme.FontSize.caption, weight: .bold)) },
            content: { Text("Contenu de la liste").frame(maxWidth: .infinity, alignment: .leading) }
        )
    }
    .padding()
    .background(Color.grymBgDark)
    .environmentObject(LocalizationManager())
    .environment(\.theme, GrymBlueTheme())
}
