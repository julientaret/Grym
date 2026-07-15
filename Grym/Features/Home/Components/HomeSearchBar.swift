//
//  HomeSearchBar.swift
//  Grym
//
//  Barre de recherche locale de l'accueil (filtre wikis + jeux).
//

import SwiftUI

struct HomeSearchBar: View {
    @Binding var text: String

    @EnvironmentObject private var localization: LocalizationManager
    @Environment(\.theme) private var theme

    var body: some View {
        HStack(spacing: Theme.Spacing.small) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: Theme.FontSize.body, weight: .medium))
                .foregroundStyle(theme.secondaryText)

            TextField(
                localization.string(.homeSearchPlaceholder),
                text: $text
            )
            .foregroundStyle(theme.primaryText)
            .autocorrectionDisabled()
            .textInputAutocapitalization(.never)

            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(theme.secondaryText)
                }
            }
        }
        .padding(.horizontal, Theme.Spacing.medium)
        .padding(.vertical, Theme.Spacing.small + 2)
        .background(
            RoundedRectangle(cornerRadius: Theme.Radius.medium, style: .continuous)
                .fill(theme.surface.opacity(0.6))
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.Radius.medium, style: .continuous)
                        .stroke(.white.opacity(0.06), lineWidth: 1)
                )
        )
    }
}

#Preview {
    HomeSearchBar(text: .constant(""))
        .padding()
        .background(Color.grymBgDark)
        .environmentObject(LocalizationManager())
        .environment(\.theme, GrymBlueTheme())
}
