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
            Form {
                Section(localization.string(.profileThemeLabel)) {
                    ThemePickerComponent()
                }
                Section(localization.string(.profileLanguageLabel)) {
                    LanguagePickerComponent()
                }
            }
            .navigationTitle(localization.string(.tabProfile))
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(LocalizationManager())
        .environmentObject(ThemeManager())
        .environment(\.theme, GrymBlueTheme())
}
