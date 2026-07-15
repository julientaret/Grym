//
//  PinnedWikisSection.swift
//  Grym
//
//  Section « Épinglés » : en-tête + défilement horizontal des cartes.
//

import SwiftUI

struct PinnedWikisSection: View {
    let wikis: [WikiSummary]
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
                        PinnedWikiCard(wiki: wiki)
                    }
                }
                .padding(.horizontal, Theme.Spacing.large)
            }
        }
    }
}

#Preview {
    PinnedWikisSection(
        wikis: [
            WikiSummary(title: "Elden Ring", coverTint: Color(hex: 0xE0A458),
                        year: 2022, platform: "PS5", blockCount: 63, photoCount: 18,
                        listCount: 9, score: 92, updatedAt: Date().addingTimeInterval(-7200)),
            WikiSummary(title: "Subnautica", coverTint: Color(hex: 0x2FA9D8),
                        year: 2018, platform: "PC", blockCount: 47, photoCount: 24,
                        listCount: 5, score: 76, updatedAt: Date().addingTimeInterval(-259200))
        ],
        totalCount: 7
    )
    .padding(.vertical)
    .background(Color.grymBgDark)
    .environmentObject(LocalizationManager())
    .environment(\.theme, GrymBlueTheme())
}
