//
//  RootTabView.swift
//  Grym
//
//  Navigation principale de l'app : TabView à trois onglets
//  (Accueil, Mes jeux, Profil). Gère aussi l'indexation Spotlight et
//  l'ouverture d'un résultat de la recherche système.
//

import CoreSpotlight
import SwiftData
import SwiftUI

struct RootTabView: View {
    @EnvironmentObject private var localization: LocalizationManager
    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var reviewPrompt: ReviewPromptManager
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        TabView(selection: $router.selectedTab) {
            HomeView()
                .tabItem {
                    Label(localization.string(.tabHome), systemImage: "house.fill")
                }
                .tag(RootTab.home)

            MyGamesView()
                .tabItem {
                    Label(localization.string(.tabMyGames), systemImage: "gamecontroller.fill")
                }
                .tag(RootTab.myGames)

            ProfileView()
                .tabItem {
                    Label(localization.string(.tabProfile), systemImage: "person.crop.circle")
                }
                .tag(RootTab.profile)
        }
        .task {
            SpotlightIndexer.reindexAll(context: modelContext)
            reviewPrompt.evaluateAtLaunch(gameCount: gameCount)
        }
        .sheet(isPresented: $reviewPrompt.isPresenting) {
            ReviewPromptView()
        }
        // L'index reflète l'état laissé par la session : réindexation à la sortie.
        .onChange(of: scenePhase) { _, phase in
            guard phase == .background else { return }
            SpotlightIndexer.reindexAll(context: modelContext)
        }
        .onContinueUserActivity(CSSearchableItemActionType) { activity in
            guard let id = activity.userInfo?[CSSearchableItemActivityIdentifier] as? String,
                  let target = SpotlightIndexer.target(for: id, context: modelContext)
            else { return }
            router.open(target)
        }
    }

    /// Nombre de jeux enregistrés, base du palier de la demande de note.
    private var gameCount: Int {
        (try? modelContext.fetchCount(FetchDescriptor<Game>())) ?? 0
    }
}

#Preview {
    RootTabView()
        .modelContainer(PreviewSampleData.container)
        .environmentObject(LocalizationManager())
        .environmentObject(ThemeManager())
        .environmentObject(PreferencesManager())
        .environmentObject(PremiumManager())
        .environmentObject(AppRouter())
        .environmentObject(ReviewPromptManager())
        .environment(\.theme, GrymBlueTheme())
}
