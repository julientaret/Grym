//
//  GrymApp.swift
//  Grym
//
//  Created by Julien TARET on 30/05/2026.
//

import SwiftUI

@main
struct GrymApp: App {
    @StateObject private var localization = LocalizationManager.shared

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environmentObject(localization)
        }
    }
}
