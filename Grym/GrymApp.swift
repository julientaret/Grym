//
//  GrymApp.swift
//  Grym
//
//  Created by Julien TARET on 30/05/2026.
//

import SwiftData
import SwiftUI

@main
struct GrymApp: App {
    @StateObject private var localization = LocalizationManager.shared
    @StateObject private var themeManager = ThemeManager()

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environmentObject(localization)
                .environmentObject(themeManager)
                .environment(\.theme, themeManager.theme)
                .tint(themeManager.theme.accent)
        }
        .modelContainer(for: [Game.self, Wiki.self, Page.self, Block.self])
    }
}
