//
//  SearchView.swift
//  Grym
//
//  Onglet Rechercher — recherche de jeux via IGDB (placeholder à ce stade).
//

import SwiftUI

struct SearchView: View {
    @EnvironmentObject private var localization: LocalizationManager

    var body: some View {
        NavigationStack {
            VStack(spacing: Theme.Spacing.medium) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: Theme.FontSize.largeTitle))
                    .foregroundStyle(Theme.Colors.accent)
                Text(localization.string(.tabSearch))
                    .font(.system(size: Theme.FontSize.title, weight: .semibold))
                    .foregroundStyle(Theme.Colors.secondaryText)
            }
            .navigationTitle(localization.string(.tabSearch))
        }
    }
}

#Preview {
    SearchView()
        .environmentObject(LocalizationManager())
}
