//
//  ProfileSectionCard.swift
//  Grym
//
//  Carte de section du profil : en-tête accentué + contenu réglable,
//  sur la surface translucide du design system.
//

import SwiftUI

struct ProfileSectionCard<Content: View>: View {
    let systemImage: String
    let title: String
    @ViewBuilder var content: Content

    @Environment(\.theme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.medium) {
            SectionHeaderView(systemImage: systemImage, title: title)

            VStack(alignment: .leading, spacing: Theme.Spacing.large) {
                content
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
        .padding(.horizontal, Theme.Spacing.large)
    }
}

#Preview {
    ProfileSectionCard(systemImage: "paintbrush.fill", title: "Apparence") {
        Text("Contenu")
    }
    .padding(.vertical)
    .background(Color.grymBgDark)
    .environment(\.theme, GrymBlueTheme())
}
