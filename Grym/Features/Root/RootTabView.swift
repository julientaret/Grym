//
//  RootTabView.swift
//  Grym
//
//  Navigation principale de l'app : TabView à trois onglets
//  (Notes, Rechercher, Profil).
//

import SwiftUI

struct RootTabView: View {
    @EnvironmentObject private var localization: LocalizationManager

    var body: some View {
        TabView {
            NotesView()
                .tabItem {
                    Label(localization.string(.tabNotes), systemImage: "book.closed")
                }

            SearchView()
                .tabItem {
                    Label(localization.string(.tabSearch), systemImage: "magnifyingglass")
                }

            ProfileView()
                .tabItem {
                    Label(localization.string(.tabProfile), systemImage: "person.crop.circle")
                }
        }
    }
}

#Preview {
    RootTabView()
        .environmentObject(LocalizationManager())
        .environmentObject(ThemeManager())
        .environment(\.theme, GrymBlueTheme())
}
