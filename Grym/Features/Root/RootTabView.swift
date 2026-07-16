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
            HomeView()
                .tabItem {
                    Label(localization.string(.tabHome), systemImage: "house.fill")
                }

            MyGamesView()
                .tabItem {
                    Label(localization.string(.tabMyGames), systemImage: "gamecontroller.fill")
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
