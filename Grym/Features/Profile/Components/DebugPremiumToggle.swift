//
//  DebugPremiumToggle.swift
//  Grym
//
//  Interrupteur de développement simulant le premium. Compilé uniquement
//  en DEBUG : absent des builds Release soumises à l'App Store.
//

#if DEBUG
import SwiftUI

struct DebugPremiumToggle: View {
    @EnvironmentObject private var localization: LocalizationManager
    @EnvironmentObject private var premium: PremiumManager
    @Environment(\.theme) private var theme

    var body: some View {
        Toggle(isOn: $premium.debugPremiumOverride) {
            Text(localization.string(.profileDebugPremium))
                .font(.system(size: Theme.FontSize.body - 1, weight: .semibold))
                .foregroundStyle(theme.primaryText)
        }
        .tint(theme.accent)
    }
}

#Preview {
    DebugPremiumToggle()
        .padding()
        .background(Color.grymBlueBgDark)
        .environmentObject(LocalizationManager())
        .environmentObject(PremiumManager())
        .environment(\.theme, GrymBlueTheme())
}
#endif
