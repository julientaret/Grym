//
//  ThemePickerComponent.swift
//  Grym
//
//  Sélecteur de thème : bascule le thème actif via le ThemeManager.
//

import SwiftUI

struct ThemePickerComponent: View {
    @EnvironmentObject private var localization: LocalizationManager
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        Picker(localization.string(.profileThemeLabel), selection: selection) {
            ForEach(ThemeID.allCases) { id in
                Text(localization.string(id.nameKey)).tag(id)
            }
        }
        .pickerStyle(.segmented)
    }

    /// Lie la sélection du picker au thème actif du manager.
    private var selection: Binding<ThemeID> {
        Binding(
            get: { themeManager.theme.id },
            set: { themeManager.select($0) }
        )
    }
}

#Preview {
    Form {
        ThemePickerComponent()
    }
    .environmentObject(LocalizationManager())
    .environmentObject(ThemeManager())
}
