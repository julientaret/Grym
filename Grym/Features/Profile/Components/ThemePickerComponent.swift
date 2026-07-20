//
//  ThemePickerComponent.swift
//  Grym
//
//  Sélecteur de thème : grille de vignettes d'aperçu. Les thèmes premium
//  ouvrent le prompt d'upgrade au lieu d'être appliqués.
//

import SwiftUI

struct ThemePickerComponent: View {
    @EnvironmentObject private var localization: LocalizationManager
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var premium: PremiumManager

    @State private var showingUpgrade = false

    private let columns = [
        GridItem(.flexible(), spacing: Theme.Spacing.medium),
        GridItem(.flexible(), spacing: Theme.Spacing.medium)
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: Theme.Spacing.medium) {
            ForEach(ThemeID.allCases) { id in
                Button { select(id) } label: {
                    ThemeSwatchView(
                        themeID: id,
                        isSelected: id == themeManager.theme.id,
                        isLocked: isLocked(id)
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .animation(.easeInOut(duration: Theme.AnimationDuration.medium), value: themeManager.theme.id)
        .sheet(isPresented: $showingUpgrade) {
            PremiumUpgradeView()
        }
    }

    private func isLocked(_ id: ThemeID) -> Bool {
        id.requiresPremium && !premium.isPremium
    }

    /// Applique le thème, ou propose l'upgrade s'il est verrouillé.
    private func select(_ id: ThemeID) {
        if isLocked(id) {
            showingUpgrade = true
        } else {
            themeManager.select(id)
        }
    }
}

#Preview {
    ThemePickerComponent()
        .padding()
        .background(Color.grymBlueBgDark)
        .environmentObject(LocalizationManager())
        .environmentObject(ThemeManager())
        .environmentObject(PremiumManager())
}
