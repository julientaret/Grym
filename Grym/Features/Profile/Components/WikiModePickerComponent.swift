//
//  WikiModePickerComponent.swift
//  Grym
//
//  Sélecteur du mode d'affichage des pages des wikis (préférence globale).
//

import SwiftUI

struct WikiModePickerComponent: View {
    @EnvironmentObject private var localization: LocalizationManager
    @EnvironmentObject private var preferences: PreferencesManager

    var body: some View {
        VStack(spacing: Theme.Spacing.small) {
            Picker("", selection: selection) {
                ForEach(WikiPagesMode.allCases) { mode in
                    Label(localization.string(mode.nameKey), systemImage: mode.systemImage)
                        .tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .labelsHidden()

            WikiModePreviewComponent(mode: preferences.wikiPagesMode)
        }
    }

    /// Lie la sélection du picker à la préférence globale.
    private var selection: Binding<WikiPagesMode> {
        Binding(
            get: { preferences.wikiPagesMode },
            set: { preferences.selectWikiPagesMode($0) }
        )
    }
}

#Preview {
    WikiModePickerComponent()
        .padding()
        .background(Color.grymBgDark)
        .environmentObject(LocalizationManager())
        .environmentObject(PreferencesManager())
}
