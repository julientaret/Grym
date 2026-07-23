//
//  ChecklistBlockView.swift
//  Grym
//
//  Bloc checklist : titre, barre de progression, items cochables.
//  Édité en mémoire puis ré-encodé dans `Block.content` (JSON).
//

import SwiftUI

struct ChecklistBlockView: View {
    @Bindable var block: Block
    /// Bloc tout juste créé : son nom prend le focus à l'apparition.
    var autofocusTitle: Bool = false
    var onTitleFocused: () -> Void = {}
    var actions: BlockActions?

    @EnvironmentObject private var localization: LocalizationManager
    @Environment(\.theme) private var theme

    @State private var content = ChecklistContent()

    private var accent: Color { BlockType.checklist.accent(in: theme) }

    private var progress: Double {
        guard !content.items.isEmpty else { return 0 }
        return Double(content.doneCount) / Double(content.items.count)
    }

    var body: some View {
        BlockCardView(
            type: .checklist,
            title: $block.title,
            autofocusTitle: autofocusTitle,
            onTitleFocused: onTitleFocused,
            actions: actions,
            accessory: { counter },
            content: { items }
        )
        .onAppear {
            content = block.checklist
            // Les listes créées avant `Block.title` portaient leur nom dans le
            // JSON : on le remonte une fois sur le bloc, puis on l'oublie.
            if block.title.isEmpty, !content.title.isEmpty {
                block.title = content.title
                content.title = ""
            }
        }
        .onChange(of: content) { _, newValue in
            block.checklist = newValue
        }
    }

    private var items: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.small) {
            progressBar

            if !content.items.isEmpty {
                VStack(spacing: 0) {
                    ForEach($content.items) { $item in
                        itemRow($item)
                    }
                }
                .padding(.top, Theme.Spacing.xSmall)
            }

            addItemButton
        }
    }

    // MARK: Compteur et progression

    private var counter: some View {
        Text("\(content.doneCount)/\(content.items.count)")
            .font(.system(size: Theme.FontSize.caption, weight: .bold))
            .foregroundStyle(content.doneCount == content.items.count && !content.items.isEmpty
                             ? accent : theme.secondaryText)
            .monospacedDigit()
    }

    private var progressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(theme.secondaryText.opacity(0.15))
                Capsule()
                    .fill(accent)
                    .frame(width: geo.size.width * progress)
            }
        }
        .frame(height: Theme.Size.checklistProgressHeight)
        .animation(.snappy, value: progress)
    }

    // MARK: Item

    private func itemRow(_ item: Binding<ChecklistItem>) -> some View {
        HStack(spacing: Theme.Spacing.small) {
            Button {
                item.done.wrappedValue.toggle()
            } label: {
                Image(systemName: item.done.wrappedValue ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: Theme.FontSize.body + 2))
                    .foregroundStyle(item.done.wrappedValue ? accent : theme.secondaryText.opacity(0.6))
                    .frame(width: Theme.Size.checklistTapTarget,
                           height: Theme.Size.checklistTapTarget)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            TextField(localization.string(.checklistItemPlaceholder), text: item.text)
                .font(.system(size: Theme.FontSize.body - 1))
                .foregroundStyle(item.done.wrappedValue ? theme.secondaryText : theme.primaryText)
                .strikethrough(item.done.wrappedValue)

            Button {
                content.items.removeAll { $0.id == item.id }
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: Theme.FontSize.caption - 1, weight: .bold))
                    .foregroundStyle(theme.secondaryText.opacity(0.5))
                    .frame(width: Theme.Size.checklistTapTarget,
                           height: Theme.Size.checklistTapTarget)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(localization.string(.commonDelete))
        }
    }

    private var addItemButton: some View {
        Button {
            content.items.append(ChecklistItem())
        } label: {
            Label(localization.string(.checklistAddItem), systemImage: "plus.circle.fill")
                .font(.system(size: Theme.FontSize.caption, weight: .semibold))
                .foregroundStyle(accent)
        }
        .buttonStyle(.plain)
        .padding(.top, Theme.Spacing.xSmall)
    }
}

#Preview {
    let block = Block(type: .checklist, title: "Remembrance bosses", content: "", order: 0)
    block.checklist = ChecklistContent(items: [
        ChecklistItem(text: "Godrick the Grafted", done: true),
        ChecklistItem(text: "Starscourge Radahn", done: false)
    ])
    return ChecklistBlockView(block: block)
        .padding()
        .background(Color.grymBgDark)
        .environmentObject(LocalizationManager())
        .environment(\.theme, GrymBlueTheme())
}
