//
//  ProfileView.swift
//  Grym
//
//  Onglet Profil — préférences utilisateur (apparence, langue, affichage),
//  présentées en cartes sur le fond dégradé Grym.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var localization: LocalizationManager
    @Environment(\.theme) private var theme

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: Theme.Spacing.large) {
                    ProfileHeaderView()
                        .padding(.horizontal, Theme.Spacing.large)

                    appearanceSection

                    displaySection
                }
                .padding(.top, Theme.Spacing.small)
                .padding(.bottom, Theme.Spacing.xLarge)
            }
            .background(background)
            .navigationBarHidden(true)
        }
    }

    // MARK: Sections

    private var appearanceSection: some View {
        ProfileSectionCard(
            systemImage: "paintbrush.fill",
            title: localization.string(.profileAppearanceSection)
        ) {
            ProfileSettingRow(title: localization.string(.profileThemeLabel)) {
                ThemePickerComponent()
            }
            ProfileSettingRow(title: localization.string(.profileLanguageLabel)) {
                LanguagePickerComponent()
            }
        }
    }

    private var displaySection: some View {
        ProfileSectionCard(
            systemImage: "square.grid.2x2.fill",
            title: localization.string(.profileDisplaySection)
        ) {
            ProfileSettingRow(
                title: localization.string(.profileWikiModeLabel),
                hint: localization.string(.profileWikiModeHint)
            ) {
                WikiModePickerComponent()
            }
        }
    }

    // MARK: Fond

    private var background: some View {
        ZStack {
            LinearGradient(
                colors: [theme.backgroundDeep, theme.background],
                startPoint: .top,
                endPoint: .bottom
            )
            RadialGradient(
                colors: [theme.glow.opacity(0.55), .clear],
                center: UnitPoint(x: 0.5, y: 0.0),
                startRadius: 4,
                endRadius: 360
            )
        }
        .ignoresSafeArea()
    }
}

#Preview {
    ProfileView()
        .environmentObject(LocalizationManager())
        .environmentObject(ThemeManager())
        .environmentObject(PreferencesManager())
        .environment(\.theme, GrymBlueTheme())
}
