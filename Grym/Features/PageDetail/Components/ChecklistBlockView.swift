//
//  ChecklistBlockView.swift
//  Grym
//
//  Bloc checklist : titre, items cochables et progression.
//  Édité en mémoire puis ré-encodé dans `Block.content` (JSON).
//

import SwiftUI

struct ChecklistBlockView: View {
    @Bindable var block: Block

    @EnvironmentObject private var localization: LocalizationManager
    @Environment(\.theme) private var theme

    @State private var content = ChecklistContent()

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.small) {
            header
            ForEach($content.items) { $item in
                itemRow($item)
            }
            addItemButton
        }
        .padding(Theme.Spacing.medium)
        .background(
            RoundedRectangle(cornerRadius: Theme.Radius.medium, style: .continuous)
                .fill(theme.surface.opacity(0.4))
        )
        .onAppear { content = block.checklist }
        .onChange(of: content) { _, newValue in
            block.checklist = newValue
        }
    }

    // MARK: En-tête

    private var header: some View {
        HStack {
            TextField(localization.string(.checklistTitlePlaceholder), text: $content.title)
                .font(.system(size: Theme.FontSize.caption, weight: .bold))
                .foregroundStyle(theme.accent)
                .textInputAutocapitalization(.characters)

            Spacer()

            Text("\(content.doneCount)/\(content.items.count)")
                .font(.system(size: Theme.FontSize.caption, weight: .semibold))
                .foregroundStyle(theme.secondaryText)
        }
    }

    // MARK: Item

    private func itemRow(_ item: Binding<ChecklistItem>) -> some View {
        HStack(spacing: Theme.Spacing.small) {
            Button {
                item.done.wrappedValue.toggle()
            } label: {
                Image(systemName: item.done.wrappedValue ? "checkmark.square.fill" : "square")
                    .font(.system(size: Theme.FontSize.body))
                    .foregroundStyle(item.done.wrappedValue ? theme.accent : theme.secondaryText)
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
                    .font(.system(size: Theme.FontSize.caption, weight: .semibold))
                    .foregroundStyle(theme.secondaryText.opacity(0.6))
            }
            .buttonStyle(.plain)
        }
    }

    private var addItemButton: some View {
        Button {
            content.items.append(ChecklistItem())
        } label: {
            Label(localization.string(.checklistAddItem), systemImage: "plus")
                .font(.system(size: Theme.FontSize.caption, weight: .semibold))
                .foregroundStyle(theme.accent)
        }
        .buttonStyle(.plain)
        .padding(.top, Theme.Spacing.xSmall)
    }
}

#Preview {
    let block = Block(type: .checklist, content: "", order: 0)
    block.checklist = ChecklistContent(title: "REMEMBRANCE BOSSES", items: [
        ChecklistItem(text: "Godrick the Grafted", done: true),
        ChecklistItem(text: "Starscourge Radahn", done: false)
    ])
    return ChecklistBlockView(block: block)
        .padding()
        .background(Color.grymBgDark)
        .environmentObject(LocalizationManager())
        .environment(\.theme, GrymBlueTheme())
}
