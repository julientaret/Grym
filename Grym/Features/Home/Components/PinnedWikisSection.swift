//
//  PinnedWikisSection.swift
//  Grym
//
//  Section « Épinglés » : en-tête + défilement horizontal des cartes.
//

import SwiftData
import SwiftUI

struct PinnedWikisSection: View {
    let wikis: [Wiki]
    let totalCount: Int

    @EnvironmentObject private var localization: LocalizationManager

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.medium) {
            SectionHeaderView(
                systemImage: "pin.fill",
                title: localization.string(.homePinned),
                trailingCount: totalCount
            )
            .padding(.horizontal, Theme.Spacing.large)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: Theme.Spacing.medium) {
                    ForEach(wikis) { wiki in
                        if let summary = WikiSummary(wiki: wiki) {
                            NavigationLink(value: wiki) {
                                PinnedWikiCard(wiki: summary)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(.horizontal, Theme.Spacing.large)
            }
        }
    }
}

#Preview {
    NavigationStack {
        PinnedWikisSection(wikis: [PreviewSampleData.sampleWiki], totalCount: 7)
    }
    .modelContainer(PreviewSampleData.container)
    .padding(.vertical)
    .background(Color.grymBgDark)
    .environmentObject(LocalizationManager())
    .environment(\.theme, GrymBlueTheme())
}
