//
//  ProfileView.swift
//  Grym
//
//  Onglet Profil — préférences et données utilisateur (placeholder à ce stade).
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var localization: LocalizationManager

    var body: some View {
        NavigationStack {
            VStack(spacing: Theme.Spacing.medium) {
                Image(systemName: "person.crop.circle")
                    .font(.system(size: Theme.FontSize.largeTitle))
                    .foregroundStyle(Theme.Colors.accent)
                Text(localization.string(.tabProfile))
                    .font(.system(size: Theme.FontSize.title, weight: .semibold))
                    .foregroundStyle(Theme.Colors.secondaryText)
            }
            .navigationTitle(localization.string(.tabProfile))
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(LocalizationManager())
}
