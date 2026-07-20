//
//  StudioCreditComponent.swift
//  Grym
//
//  Encart « Une création AppleMousse Studio » : logo, libellé et lien
//  vers le site du studio.
//

import SwiftUI

struct StudioCreditComponent: View {
    @EnvironmentObject private var localization: LocalizationManager
    @Environment(\.theme) private var theme

    private static let studioURL = URL(string: "https://applemousse-studio.fr")

    var body: some View {
        Group {
            if let url = Self.studioURL {
                Link(destination: url) { card }
                    .buttonStyle(.plain)
            } else {
                card
            }
        }
        .padding(.horizontal, Theme.Spacing.large)
    }

    private var card: some View {
        HStack(spacing: Theme.Spacing.medium) {
            Image("applemousse-logo")
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)

            VStack(alignment: .leading, spacing: Theme.Spacing.xSmall) {
                Text(localization.string(.profileStudioCreditPrefix))
                    .font(.system(size: Theme.FontSize.caption))
                    .foregroundStyle(theme.secondaryText)

                Text(localization.string(.profileStudioCreditName))
                    .font(.system(size: Theme.FontSize.body, weight: .semibold))
                    .foregroundStyle(theme.primaryText)
            }

            Spacer(minLength: Theme.Spacing.small)

            Image(systemName: "arrow.up.right")
                .font(.system(size: Theme.FontSize.body, weight: .semibold))
                .foregroundStyle(theme.secondaryText)
        }
        .padding(Theme.Spacing.medium)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: Theme.Radius.large, style: .continuous)
                .fill(theme.surface.opacity(0.5))
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.Radius.large, style: .continuous)
                        .stroke(.white.opacity(0.06), lineWidth: 1)
                )
        )
    }
}

#Preview {
    StudioCreditComponent()
        .padding(.vertical)
        .background(Color.grymBgDark)
        .environmentObject(LocalizationManager())
        .environment(\.theme, GrymBlueTheme())
}
