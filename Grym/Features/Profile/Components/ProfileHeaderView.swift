//
//  ProfileHeaderView.swift
//  Grym
//
//  En-tête du profil : titre et tagline, aligné sur le style de l'accueil.
//

import SwiftUI

struct ProfileHeaderView: View {
    @EnvironmentObject private var localization: LocalizationManager
    @Environment(\.theme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xSmall) {
            Text(localization.string(.tabProfile))
                .font(.system(size: Theme.FontSize.largeTitle, weight: .bold))
                .foregroundStyle(theme.primaryText)
            Text(localization.string(.profileSubtitle))
                .font(.system(size: Theme.FontSize.caption, weight: .medium))
                .foregroundStyle(theme.secondaryText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    ProfileHeaderView()
        .padding()
        .background(Color.grymBgDark)
        .environmentObject(LocalizationManager())
        .environment(\.theme, GrymBlueTheme())
}
