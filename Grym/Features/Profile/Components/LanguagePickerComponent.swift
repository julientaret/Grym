//
//  LanguagePickerComponent.swift
//  Grym
//
//  Sélecteur de langue : bascule la langue active via le LocalizationManager.
//

import SwiftUI

struct LanguagePickerComponent: View {
    @EnvironmentObject private var localization: LocalizationManager

    var body: some View {
        Picker("", selection: selection) {
            ForEach(AppLanguage.allCases, id: \.self) { language in
                Text(language.displayName).tag(language)
            }
        }
        .pickerStyle(.segmented)
        .labelsHidden()
    }

    /// Lie la sélection du picker à la langue active du manager.
    private var selection: Binding<AppLanguage> {
        Binding(
            get: { localization.language },
            set: { localization.select($0) }
        )
    }
}

#Preview {
    Form {
        LanguagePickerComponent()
    }
    .environmentObject(LocalizationManager())
}
