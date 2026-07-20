//
//  ProfileSettingRow.swift
//  Grym
//
//  Ligne de réglage du profil : intitulé, aide optionnelle, puis contrôle.
//

import SwiftUI

struct ProfileSettingRow<Content: View>: View {
    let title: String
    var hint: String? = nil
    @ViewBuilder var content: Content

    @Environment(\.theme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.small) {
            Text(title)
                .font(.system(size: Theme.FontSize.body - 1, weight: .semibold))
                .foregroundStyle(theme.primaryText)

            content

            if let hint {
                Text(hint)
                    .font(.system(size: Theme.FontSize.caption, weight: .regular))
                    .foregroundStyle(theme.secondaryText)
            }
        }
    }
}

#Preview {
    ProfileSettingRow(title: "Pages des wikis", hint: "S'applique à tous vos wikis.") {
        Text("Contrôle")
    }
    .padding()
    .background(Color.grymBgDark)
    .environment(\.theme, GrymBlueTheme())
}
