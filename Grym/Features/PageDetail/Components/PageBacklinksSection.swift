//
//  PageBacklinksSection.swift
//  Grym
//
//  Section « Rétroliens » d'une page : les autres pages du wiki qui la
//  citent via un lien `[[Titre]]`.
//

import SwiftUI

struct PageBacklinksSection: View {
    let pages: [Page]
    var onOpen: (Page) -> Void

    @EnvironmentObject private var localization: LocalizationManager
    @Environment(\.theme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.small) {
            SectionHeaderView(
                systemImage: "arrow.turn.up.left",
                title: localization.string(.backlinksTitle),
                trailingCount: pages.count
            )

            ForEach(pages) { page in
                Button { onOpen(page) } label: {
                    HStack(spacing: Theme.Spacing.small) {
                        Image(systemName: "book.pages")
                            .font(.system(size: Theme.FontSize.caption, weight: .semibold))
                            .foregroundStyle(theme.accent)
                        Text(page.title)
                            .font(.system(size: Theme.FontSize.caption, weight: .medium))
                            .foregroundStyle(theme.primaryText)
                        Spacer()
                    }
                    .padding(Theme.Spacing.small)
                    .background(
                        RoundedRectangle(cornerRadius: Theme.Radius.small, style: .continuous)
                            .fill(theme.surface.opacity(0.4))
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }
}

#Preview {
    PageBacklinksSection(pages: [], onOpen: { _ in })
        .padding()
        .background(Color.grymBgDark)
        .environmentObject(LocalizationManager())
        .environment(\.theme, GrymBlueTheme())
}
