//
//  RecentActivitySection.swift
//  Grym
//
//  Section « Activité récente » : en-tête + carte listant les entrées,
//  séparées par des filets.
//

import SwiftUI

struct RecentActivitySection: View {
    let entries: [ActivityEntry]
    /// Appelé au tap sur une entrée (navigation gérée par le parent).
    let onSelect: (ActivityEntry) -> Void

    @EnvironmentObject private var localization: LocalizationManager
    @Environment(\.theme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.medium) {
            SectionHeaderView(
                systemImage: "sparkles",
                title: localization.string(.homeRecentActivity)
            )

            VStack(spacing: 0) {
                ForEach(Array(entries.enumerated()), id: \.element.id) { index, entry in
                    Button { onSelect(entry) } label: {
                        ActivityRowView(entry: entry)
                    }
                    .buttonStyle(.plain)
                    if index < entries.count - 1 {
                        Divider().overlay(theme.secondaryText.opacity(0.15))
                    }
                }
            }
            .padding(.horizontal, Theme.Spacing.medium)
            .background(
                RoundedRectangle(cornerRadius: Theme.Radius.large, style: .continuous)
                    .fill(theme.surface.opacity(0.5))
                    .overlay(
                        RoundedRectangle(cornerRadius: Theme.Radius.large, style: .continuous)
                            .stroke(.white.opacity(0.06), lineWidth: 1)
                    )
            )
        }
        .padding(.horizontal, Theme.Spacing.large)
    }
}

#Preview {
    RecentActivitySection(
        entries: [
            ActivityEntry(kind: .checklist, title: "Added checklist",
                          subtitle: "Elden Ring · Remembrance Bosses — 8 items",
                          coverTint: Color(hex: 0xE0A458), date: Date().addingTimeInterval(-7200)),
            ActivityEntry(kind: .photos, title: "Added 3 photos",
                          subtitle: "Baldur's Gate 3 · Tav Build — Sorcadin",
                          coverTint: Color(hex: 0xC0392B), date: Date().addingTimeInterval(-86400))
        ],
        onSelect: { _ in }
    )
    .padding(.vertical)
    .background(Color.grymBgDark)
    .environmentObject(LocalizationManager())
    .environment(\.theme, GrymBlueTheme())
}
