//
//  PageTabsView.swift
//  Grym
//
//  Mode « Onglets » du détail wiki : chips de pages + aperçu léger
//  (résumé des blocs) de la page sélectionnée, avec accès à l'éditeur.
//

import SwiftData
import SwiftUI

struct PageTabsView: View {
    let pages: [Page]
    @Binding var selectedID: PersistentIdentifier?
    let onOpen: (Page) -> Void

    @EnvironmentObject private var localization: LocalizationManager
    @Environment(\.theme) private var theme

    private var selectedPage: Page? {
        pages.first { $0.persistentModelID == selectedID } ?? pages.first
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.medium) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Theme.Spacing.small) {
                    ForEach(pages) { page in
                        chip(page)
                    }
                }
            }

            if let page = selectedPage {
                preview(page)
            }
        }
    }

    // MARK: Chip

    private func chip(_ page: Page) -> some View {
        let isSelected = page.persistentModelID == selectedPage?.persistentModelID
        return Button {
            selectedID = page.persistentModelID
        } label: {
            Text(page.title)
                .font(.system(size: Theme.FontSize.caption, weight: .semibold))
                .foregroundStyle(isSelected ? .white : theme.secondaryText)
                .padding(.horizontal, Theme.Spacing.medium)
                .padding(.vertical, Theme.Spacing.small)
                .background(
                    Capsule().fill(isSelected ? theme.accent : theme.surface.opacity(0.5))
                )
        }
        .buttonStyle(.plain)
    }

    // MARK: Aperçu de page

    private func preview(_ page: Page) -> some View {
        let blocks = page.blocks.sorted { $0.order < $1.order }
        return VStack(alignment: .leading, spacing: Theme.Spacing.small) {
            Text(page.title)
                .font(.system(size: Theme.FontSize.body, weight: .bold))
                .foregroundStyle(theme.primaryText)
            Text("\(blocks.count) \(localization.string(.statBlocks))")
                .font(.system(size: Theme.FontSize.caption))
                .foregroundStyle(theme.secondaryText)

            ForEach(blocks.prefix(6)) { block in
                blockSummary(block)
            }

            Button {
                onOpen(page)
            } label: {
                HStack(spacing: Theme.Spacing.xSmall) {
                    Text(localization.string(.wikiOpenEditor))
                    Image(systemName: "chevron.right")
                }
                .font(.system(size: Theme.FontSize.caption, weight: .semibold))
                .foregroundStyle(theme.accent)
            }
            .buttonStyle(.plain)
            .padding(.top, Theme.Spacing.xSmall)
        }
        .padding(Theme.Spacing.medium)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: Theme.Radius.large, style: .continuous)
                .fill(theme.surface.opacity(0.4))
        )
    }

    private func blockSummary(_ block: Block) -> some View {
        HStack(spacing: Theme.Spacing.small) {
            Image(systemName: block.type.systemImage)
                .font(.system(size: Theme.FontSize.caption, weight: .semibold))
                .foregroundStyle(theme.accent)
                .frame(width: 18)
            Text(summaryText(block))
                .font(.system(size: Theme.FontSize.caption))
                .foregroundStyle(theme.secondaryText)
                .lineLimit(1)
        }
    }

    private func summaryText(_ block: Block) -> String {
        switch block.type {
        case .text:
            let line = block.content
                .split(separator: "\n")
                .first
                .map(String.init) ?? ""
            return line.isEmpty ? localization.string(.blockTypeText) : line
        case .checklist:
            let c = block.checklist
            let title = c.title.isEmpty ? localization.string(.blockTypeChecklist) : c.title
            return "\(title) · \(c.doneCount)/\(c.items.count)"
        case .photo:
            return "\(block.photos.fileNames.count) \(localization.string(.statPhotos))"
        case .map:
            return "\(localization.string(.blockTypeMap)) · \(block.map.pins.count)"
        }
    }
}
