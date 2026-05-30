//
//  NotesView.swift
//  Grym
//
//  Onglet Notes — carnet de jeu personnel (placeholder à ce stade).
//

import SwiftUI

struct NotesView: View {
    @EnvironmentObject private var localization: LocalizationManager
    @Environment(\.theme) private var theme

    var body: some View {
        NavigationStack {
            VStack(spacing: Theme.Spacing.medium) {
                Image(systemName: "book.closed")
                    .font(.system(size: Theme.FontSize.largeTitle))
                    .foregroundStyle(theme.accent)
                Text(localization.string(.tabNotes))
                    .font(.system(size: Theme.FontSize.title, weight: .semibold))
                    .foregroundStyle(theme.secondaryText)
            }
            .navigationTitle(localization.string(.tabNotes))
        }
    }
}

#Preview {
    NotesView()
        .environmentObject(LocalizationManager())
        .environment(\.theme, GrymBlueTheme())
}
