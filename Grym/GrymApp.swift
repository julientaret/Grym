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
    @StateObject private var premium = PremiumManager()
    @StateObject private var preferences = PreferencesManager()

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environmentObject(localization)
                .environmentObject(themeManager)
                .environmentObject(premium)
                .environmentObject(preferences)
                .environment(\.theme, themeManager.theme)
                .tint(themeManager.theme.accent)
                // Un thème premium ne doit pas survivre à la perte du droit.
                .task { themeManager.enforceEntitlement(isPremium: premium.isPremium) }
                .onChange(of: premium.isPremium) { _, isPremium in
                    themeManager.enforceEntitlement(isPremium: isPremium)
                }
        }
        .modelContainer(for: [Game.self, Wiki.self, Page.self, Block.self, PlaySession.self])
    }
}
