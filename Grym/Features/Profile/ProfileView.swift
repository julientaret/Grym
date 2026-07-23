//
//  ProfileView.swift
//  Grym
//
//  Onglet Profil — préférences utilisateur (apparence, langue, affichage),
//  présentées en cartes sur le fond dégradé Grym.
//

import SwiftData
import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var localization: LocalizationManager
    @Environment(\.theme) private var theme

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: Theme.Spacing.large) {
                    ProfileHeaderView()

                    StudioCreditComponent()

                    premiumSection

                    supportSection

                    appearanceSection

                    languageSection

                    displaySection

#if DEBUG
                    debugSection
#endif
                }
                .padding(.bottom, Theme.Spacing.xLarge)
            }
            .ignoresSafeArea(edges: .top)
            .background(background)
            .navigationBarHidden(true)
        }
    }

    // MARK: Sections

    private var premiumSection: some View {
        ProfileSectionCard(
            systemImage: "crown.fill",
            title: localization.string(.profilePremiumSection)
        ) {
            // La carte porte son propre libellé et son état.
            ProfileSettingRow(hint: localization.string(.profilePremiumHint)) {
                PremiumStatusCard()
            }
        }
    }

    private var supportSection: some View {
        ProfileSectionCard(
            systemImage: "star.fill",
            title: localization.string(.profileSupportSection)
        ) {
            // L'encart porte son propre libellé.
            ProfileSettingRow(hint: localization.string(.reviewPromptFooter)) {
                RateAppCard()
            }
        }
    }

    private var appearanceSection: some View {
        ProfileSectionCard(
            systemImage: "paintbrush.fill",
            title: localization.string(.profileAppearanceSection)
        ) {
            ProfileSettingRow(
                title: localization.string(.profileThemeLabel),
                hint: localization.string(.profileThemeHint)
            ) {
                ThemePickerComponent()
            }
        }
    }

    private var languageSection: some View {
        ProfileSectionCard(
            systemImage: "globe",
            title: localization.string(.profileLanguageSection)
        ) {
            // Le sélecteur suffit : le titre de section porte déjà le libellé.
            ProfileSettingRow(hint: localization.string(.profileLanguageHint)) {
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

#if DEBUG
    /// Réglages de développement, compilés hors des builds Release.
    private var debugSection: some View {
        ProfileSectionCard(
            systemImage: "hammer.fill",
            title: localization.string(.profileDebugSection)
        ) {
            // Les toggles portent leur propre libellé.
            ProfileSettingRow(hint: localization.string(.profileDebugHint)) {
                DebugPremiumToggle()
            }

            ProfileSettingRow(hint: localization.string(.profileDebugDemoDataHint)) {
                DebugDemoDataToggle()
            }
        }
    }
#endif

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
        .modelContainer(PreviewSampleData.container)
        .environmentObject(LocalizationManager())
        .environmentObject(ThemeManager())
        .environmentObject(PreferencesManager())
        .environmentObject(PremiumManager())
        .environment(\.theme, GrymBlueTheme())
}
