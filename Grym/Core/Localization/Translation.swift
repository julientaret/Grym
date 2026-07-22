//
//  Translation.swift
//  Grym
//
//  Catalogue des traductions de l'app (FR/EN).
//  Chaque texte affiché passe par une clé `TranslationKey`.
//

import Foundation

/// Langues supportées par l'application.
enum AppLanguage: String, CaseIterable {
    case french = "fr"
    case english = "en"

    /// Langue déduite des préférences système, anglais par défaut.
    nonisolated static var system: AppLanguage {
        let code = Locale.preferredLanguages.first?.prefix(2).lowercased() ?? "en"
        return AppLanguage(rawValue: String(code)) ?? .english
    }

    /// Nom natif de la langue (autonyme), ex. « Français », « English ».
    var displayName: String {
        let locale = Locale(identifier: rawValue)
        return locale.localizedString(forLanguageCode: rawValue)?.capitalized
            ?? rawValue.uppercased()
    }
}

/// Clés de traduction. Aucune string en dur dans les vues.
enum TranslationKey: String {
    case tabProfile
    case tabHome
    case profileThemeLabel
    case profileSubtitle
    case profileAppearanceSection
    case profileLanguageSection
    case profileLanguageHint
    case profileDisplaySection
    case profileWikiModeLabel
    case profileWikiModeHint
    case profileWikiModeSampleFirst
    case profileWikiModeSampleSecond
    case themeGrymBlue
    case themeGrymViolet
    case themeGrymEmerald
    case themeGrymMagenta
    case profileThemeHint
    case profileThemePremium
    case profileDebugSection
    case profileDebugPremium
    case profileDebugHint
    case profileStudioCreditPrefix
    case profileStudioCreditName
    // Home
    case appTagline
    case homeSearchPlaceholder
    case homePinned
    case homeRecentActivity
    case homeActivityNewWiki
    case homeActivityScore
    case homeActivitySession
    case homeActivityStatus
    case homeAllWikis
    case statBlocks
    case statPhotos
    case statLists
    // Game search
    case gameSearchTitle
    case gameSearchPlaceholder
    case gameSearchPrompt
    case gameSearchEmpty
    case gameSearchError
    case commonCancel
    case commonRetry
    case homeEmptyWikis
    case homeOnboardingTitle
    case homeOnboardingMessage
    case homeOnboardingStepSearch
    case homeOnboardingStepWiki
    case homeOnboardingStepScore
    case homeNoPinnedTitle
    case homeNoPinnedMessage
    case homeNoPinnedStepPin
    case homeNoPinnedStepActivity
    case myGamesEmptyTitle
    case myGamesEmptyMessage
    case myGamesEmptyStepSearch
    case myGamesEmptyStepLimit
    // Premium
    case premiumTitle
    case premiumLimitReached
    case premiumFreeHint
    case premiumBenefitUnlimited
    case premiumBenefitSync
    case premiumBenefitThemes
    case premiumBenefitExport
    case premiumBenefitWidgets
    case premiumBenefitStats
    case premiumUnlock
    case premiumRestore
    case premiumLater
    case tabMyGames
    case myGamesTitle
    case commonDelete
    // Tri de la liste des jeux
    case sortLabel
    case sortRecent
    case sortTitle
    case sortScore
    case sortReleaseYear
    case sortPlaytime
    // Wiki detail
    case wikiNoteTitle
    case wikiPrivate
    case wikiTierLabel
    case wikiPagesTitle
    case wikiNewPage
    case wikiModeList
    case wikiModeTabs
    case wikiModeCards
    case wikiOpenEditor
    case wikiNewPageDefaultTitle
    case wikiPin
    case wikiUnpin
    case wikiMediaTitle
    // Tiers de note
    case tierNaze
    case tierPasOuf
    case tierMid
    case tierTopTier
    case tierGoty
    // Éditeur de page / blocs
    case pageTitlePlaceholder
    case pageEmptyBlocks
    case addBlock
    case blockTypeText
    case blockTypeChecklist
    case blockTypePhoto
    case blockTypeMap
    case pageEmptyTitle
    case blockTypeTextHint
    case blockTypeChecklistHint
    case blockTypePhotoHint
    case blockTypeMapHint
    case photoAdd
    case mapAddImage
    case mapReplaceImage
    case mapEmptyHint
    case mapPinLabelPlaceholder
    case mapNoImageHint
    case mapFullScreen
    case mapExitFullScreen
    case commonDone
    case textBlockPlaceholder
    case checklistTitlePlaceholder
    case checklistAddItem
    case checklistItemPlaceholder
    // Statuts de progression
    case statusNone
    case statusBacklog
    case statusPlaying
    case statusCompleted
    case statusPlatinum
    case statusAbandoned
    case statusLabel
    case statusFilterAll
    case filterLabel
    case myGamesFilterEmpty
    // Journal de sessions
    case sessionsTitle
    case sessionsAdd
    case sessionsEmpty
    case sessionsTotal
    case sessionsCount
    case sessionsShowAll
    case sessionsShowLess
    case sessionEditorTitle
    case sessionEditorEditTitle
    case sessionDate
    case sessionDuration
    case sessionMood
    case sessionNote
    case sessionNotePlaceholder
    case commonSave
    case durationHourUnit
    case durationMinuteUnit
    // Ressentis de session
    case moodHyped
    case moodGood
    case moodNeutral
    case moodRough
}

/// Accès statique aux traductions.
enum Translation {

    static func value(for key: TranslationKey, language: AppLanguage) -> String {
        translations[language]?[key]
            ?? translations[.english]?[key]
            ?? key.rawValue
    }

    private static let translations: [AppLanguage: [TranslationKey: String]] = [
        .french: [
            .tabProfile: "Profil",
            .tabHome: "Accueil",
            .profileThemeLabel: "Thème",
            .profileSubtitle: "Personnalisez votre expérience",
            .profileAppearanceSection: "Apparence",
            .profileLanguageSection: "Langue",
            .profileLanguageHint: "S'applique aux textes de l'app, pas à vos contenus.",
            .profileDisplaySection: "Affichage",
            .profileWikiModeLabel: "Affichage des wikis",
            .profileWikiModeHint: "Le même réglage s'applique à tous vos jeux.",
            .profileWikiModeSampleFirst: "Quêtes",
            .profileWikiModeSampleSecond: "Builds",
            .themeGrymBlue: "Bleu",
            .themeGrymViolet: "Violet",
            .themeGrymEmerald: "Émeraude",
            .themeGrymMagenta: "Magenta",
            .profileThemeHint: "Le thème colore les fonds, les surfaces et les accents de toute l'app.",
            .profileThemePremium: "Premium",
            .profileDebugSection: "Développement",
            .profileDebugPremium: "Simuler le premium",
            .profileDebugHint: "Réglage de debug : absent des builds App Store.",
            .profileStudioCreditPrefix: "Une création",
            .profileStudioCreditName: "AppleMousse Studio",
            .appTagline: "Votre pense-bête vidéoludique",
            .homeSearchPlaceholder: "Rechercher un wiki ou un jeu…",
            .homePinned: "Épinglés",
            .homeRecentActivity: "Activité récente",
            .homeActivityNewWiki: "Nouveau wiki",
            .homeActivityScore: "Note mise à jour",
            .homeActivitySession: "Session de jeu",
            .homeActivityStatus: "Statut mis à jour",
            .homeAllWikis: "Tous les wikis",
            .statBlocks: "blocs",
            .statPhotos: "photos",
            .statLists: "listes",
            .gameSearchTitle: "Ajouter un jeu",
            .gameSearchPlaceholder: "Rechercher un jeu…",
            .gameSearchPrompt: "Recherchez un jeu à ajouter à vos wikis.",
            .gameSearchEmpty: "Aucun jeu trouvé.",
            .gameSearchError: "Recherche impossible. Réessayez.",
            .commonCancel: "Annuler",
            .commonRetry: "Réessayer",
            .homeEmptyWikis: "Aucun wiki pour l'instant.\nAppuie sur + pour ajouter un jeu.",
            .homeOnboardingTitle: "Bienvenue dans Grym",
            .homeOnboardingMessage: "Ta collection est vide. Ajoute un premier jeu pour commencer à consigner tes parties.",
            .homeOnboardingStepSearch: "Recherche un jeu dans le catalogue et ajoute-le.",
            .homeOnboardingStepWiki: "Crée des wikis : notes, checklists, photos et cartes annotées.",
            .homeOnboardingStepScore: "Donne-lui ta note personnelle de 0 à 100.",
            .homeNoPinnedTitle: "Ton tableau de bord est prêt",
            .homeNoPinnedMessage: "Rien à afficher pour l'instant : épingle tes jeux du moment pour les garder sous la main.",
            .homeNoPinnedStepPin: "Ouvre un jeu et touche l'épingle pour l'afficher ici.",
            .homeNoPinnedStepActivity: "Tes derniers ajouts et notes apparaîtront dans l'activité récente.",
            .myGamesEmptyTitle: "Aucun jeu pour l'instant",
            .myGamesEmptyMessage: "Ajoute ton premier jeu : il servira de point de départ à tes wikis.",
            .myGamesEmptyStepSearch: "Touche « Ajouter un jeu » et cherche-le par son titre.",
            .myGamesEmptyStepLimit: "Le palier gratuit couvre 10 jeux.",
            .premiumTitle: "Passez Premium",
            .premiumLimitReached: "Limite gratuite atteinte (10 jeux).",
            .premiumFreeHint: "Supprime un jeu pour en ajouter un autre gratuitement.",
            .premiumBenefitUnlimited: "Jeux illimités",
            .premiumBenefitSync: "Synchronisation iCloud",
            .premiumBenefitThemes: "Thèmes visuels",
            .premiumBenefitExport: "Export PDF / Markdown",
            .premiumBenefitWidgets: "Widgets iOS",
            .premiumBenefitStats: "Statistiques personnelles",
            .premiumUnlock: "Débloquer",
            .premiumRestore: "Restaurer l'achat",
            .premiumLater: "Plus tard",
            .tabMyGames: "Mes jeux",
            .myGamesTitle: "Mes jeux",
            .commonDelete: "Supprimer",
            .sortLabel: "Trier par",
            .sortRecent: "Récemment modifiés",
            .sortTitle: "Titre",
            .sortScore: "Note",
            .sortReleaseYear: "Date de sortie",
            .sortPlaytime: "Temps de jeu",
            .wikiNoteTitle: "TON VERDICT / 100",
            .wikiPrivate: "PRIVÉ",
            .wikiTierLabel: "TIER",
            .wikiPagesTitle: "Wikis",
            .wikiNewPage: "Nouveau wiki",
            .wikiModeList: "Liste",
            .wikiModeTabs: "Onglets",
            .wikiModeCards: "Cartes",
            .wikiOpenEditor: "Ouvrir l'éditeur",
            .wikiNewPageDefaultTitle: "Nouveau wiki",
            .wikiPin: "Épingler",
            .wikiUnpin: "Désépingler",
            .wikiMediaTitle: "Médias",
            .tierNaze: "NAZE",
            .tierPasOuf: "PAS OUF",
            .tierMid: "MID",
            .tierTopTier: "TOP TIER",
            .tierGoty: "GOTY",
            .pageTitlePlaceholder: "Titre du wiki",
            .pageEmptyBlocks: "Compose-le en empilant des blocs. Voici ceux disponibles :",
            .addBlock: "Ajouter un bloc",
            .blockTypeText: "Texte",
            .blockTypeChecklist: "Checklist",
            .blockTypePhoto: "Photo",
            .blockTypeMap: "Carte",
            .pageEmptyTitle: "Ton wiki est vierge",
            .blockTypeTextHint: "Tes notes libres : soluce, build, lore.",
            .blockTypeChecklistHint: "Une liste à cocher pour suivre ta progression.",
            .blockTypePhotoHint: "Tes captures d'écran, en pleine largeur.",
            .blockTypeMapHint: "Une carte ou une image que tu annotes de tes propres repères.",
            .photoAdd: "Ajouter des photos",
            .mapAddImage: "Ajouter une carte",
            .mapReplaceImage: "Remplacer",
            .mapEmptyHint: "Touche la carte pour ajouter un repère.",
            .mapPinLabelPlaceholder: "Nom du repère",
            .mapNoImageHint: "Aucune carte. Ajoute une image à annoter.",
            .mapFullScreen: "Afficher en plein écran",
            .mapExitFullScreen: "Fermer le plein écran",
            .commonDone: "Terminé",
            .textBlockPlaceholder: "Écris ici…",
            .checklistTitlePlaceholder: "Titre de la liste",
            .checklistAddItem: "Ajouter un élément",
            .checklistItemPlaceholder: "Élément",
            .statusNone: "Sans statut",
            .statusBacklog: "À jouer",
            .statusPlaying: "En cours",
            .statusCompleted: "Terminé",
            .statusPlatinum: "Platiné",
            .statusAbandoned: "Abandonné",
            .statusLabel: "Statut",
            .statusFilterAll: "Tous",
            .filterLabel: "Filtrer",
            .myGamesFilterEmpty: "Aucun jeu avec ce statut.",
            .sessionsTitle: "Sessions",
            .sessionsAdd: "Ajouter une session",
            .sessionsEmpty: "Aucune session consignée. Note tes parties pour suivre ton temps de jeu.",
            .sessionsTotal: "Temps de jeu",
            .sessionsCount: "sessions",
            .sessionsShowAll: "Tout afficher",
            .sessionsShowLess: "Réduire",
            .sessionEditorTitle: "Nouvelle session",
            .sessionEditorEditTitle: "Modifier la session",
            .sessionDate: "Date",
            .sessionDuration: "Durée",
            .sessionMood: "Ressenti",
            .sessionNote: "Note",
            .sessionNotePlaceholder: "Ce que tu as fait pendant cette session…",
            .commonSave: "Enregistrer",
            .durationHourUnit: "h",
            .durationMinuteUnit: "min",
            .moodHyped: "Excellent",
            .moodGood: "Bien",
            .moodNeutral: "Mitigé",
            .moodRough: "Galère"
        ],
        .english: [
            .tabProfile: "Profile",
            .tabHome: "Home",
            .profileThemeLabel: "Theme",
            .profileSubtitle: "Make the app yours",
            .profileAppearanceSection: "Appearance",
            .profileLanguageSection: "Language",
            .profileLanguageHint: "Applies to the app's own text, not to your content.",
            .profileDisplaySection: "Display",
            .profileWikiModeLabel: "Wikis display",
            .profileWikiModeHint: "The same setting applies to all your games.",
            .profileWikiModeSampleFirst: "Quests",
            .profileWikiModeSampleSecond: "Builds",
            .themeGrymBlue: "Blue",
            .themeGrymViolet: "Violet",
            .themeGrymEmerald: "Emerald",
            .themeGrymMagenta: "Magenta",
            .profileThemeHint: "The theme tints backgrounds, surfaces and accents across the app.",
            .profileThemePremium: "Premium",
            .profileDebugSection: "Development",
            .profileDebugPremium: "Simulate premium",
            .profileDebugHint: "Debug setting: not shipped in App Store builds.",
            .profileStudioCreditPrefix: "Made by",
            .profileStudioCreditName: "AppleMousse Studio",
            .appTagline: "Your video game notebook",
            .homeSearchPlaceholder: "Search a wiki or a game…",
            .homePinned: "Pinned",
            .homeRecentActivity: "Recent activity",
            .homeActivityNewWiki: "New wiki",
            .homeActivityScore: "Score updated",
            .homeActivitySession: "Play session",
            .homeActivityStatus: "Status updated",
            .homeAllWikis: "All wikis",
            .statBlocks: "blocks",
            .statPhotos: "photos",
            .statLists: "lists",
            .gameSearchTitle: "Add a game",
            .gameSearchPlaceholder: "Search a game…",
            .gameSearchPrompt: "Search a game to add to your wikis.",
            .gameSearchEmpty: "No game found.",
            .gameSearchError: "Search failed. Please try again.",
            .commonCancel: "Cancel",
            .commonRetry: "Retry",
            .homeEmptyWikis: "No wiki yet.\nTap + to add a game.",
            .homeOnboardingTitle: "Welcome to Grym",
            .homeOnboardingMessage: "Your collection is empty. Add a first game to start logging your playthroughs.",
            .homeOnboardingStepSearch: "Search the catalog for a game and add it.",
            .homeOnboardingStepWiki: "Create wikis: notes, checklists, photos and annotated maps.",
            .homeOnboardingStepScore: "Give it your personal score from 0 to 100.",
            .homeNoPinnedTitle: "Your dashboard is ready",
            .homeNoPinnedMessage: "Nothing to show yet: pin the games you are playing to keep them at hand.",
            .homeNoPinnedStepPin: "Open a game and tap the pin to show it here.",
            .homeNoPinnedStepActivity: "Your latest additions and scores will appear in recent activity.",
            .myGamesEmptyTitle: "No games yet",
            .myGamesEmptyMessage: "Add your first game: it will be the starting point of your wikis.",
            .myGamesEmptyStepSearch: "Tap “Add a game” and search it by title.",
            .myGamesEmptyStepLimit: "The free tier covers 10 games.",
            .premiumTitle: "Go Premium",
            .premiumLimitReached: "Free limit reached (10 games).",
            .premiumFreeHint: "Delete a game to add another one for free.",
            .premiumBenefitUnlimited: "Unlimited games",
            .premiumBenefitSync: "iCloud sync",
            .premiumBenefitThemes: "Visual themes",
            .premiumBenefitExport: "PDF / Markdown export",
            .premiumBenefitWidgets: "iOS widgets",
            .premiumBenefitStats: "Personal stats",
            .premiumUnlock: "Unlock",
            .premiumRestore: "Restore purchase",
            .premiumLater: "Later",
            .tabMyGames: "My games",
            .myGamesTitle: "My games",
            .commonDelete: "Delete",
            .sortLabel: "Sort by",
            .sortRecent: "Recently updated",
            .sortTitle: "Title",
            .sortScore: "Score",
            .sortReleaseYear: "Release date",
            .sortPlaytime: "Playtime",
            .wikiNoteTitle: "YOUR VERDICT / 100",
            .wikiPrivate: "PRIVATE",
            .wikiTierLabel: "TIER",
            .wikiPagesTitle: "Wikis",
            .wikiNewPage: "New wiki",
            .wikiModeList: "List",
            .wikiModeTabs: "Tabs",
            .wikiModeCards: "Cards",
            .wikiOpenEditor: "Open editor",
            .wikiNewPageDefaultTitle: "New wiki",
            .wikiPin: "Pin",
            .wikiUnpin: "Unpin",
            .wikiMediaTitle: "Media",
            .tierNaze: "TRASH",
            .tierPasOuf: "MEH",
            .tierMid: "MID",
            .tierTopTier: "TOP TIER",
            .tierGoty: "GOTY",
            .pageTitlePlaceholder: "Wiki title",
            .pageEmptyBlocks: "Build it by stacking blocks. Here are the ones available:",
            .addBlock: "Add a block",
            .blockTypeText: "Text",
            .blockTypeChecklist: "Checklist",
            .blockTypePhoto: "Photo",
            .blockTypeMap: "Map",
            .pageEmptyTitle: "Your wiki is blank",
            .blockTypeTextHint: "Free-form notes: walkthrough, build, lore.",
            .blockTypeChecklistHint: "A checklist to track your progress.",
            .blockTypePhotoHint: "Your screenshots, full width.",
            .blockTypeMapHint: "A map or any image you annotate with your own markers.",
            .photoAdd: "Add photos",
            .mapAddImage: "Add a map",
            .mapReplaceImage: "Replace",
            .mapEmptyHint: "Tap the map to add a pin.",
            .mapPinLabelPlaceholder: "Pin name",
            .mapNoImageHint: "No map yet. Add an image to annotate.",
            .mapFullScreen: "View full screen",
            .mapExitFullScreen: "Close full screen",
            .commonDone: "Done",
            .textBlockPlaceholder: "Write here…",
            .checklistTitlePlaceholder: "List title",
            .checklistAddItem: "Add an item",
            .checklistItemPlaceholder: "Item",
            .statusNone: "No status",
            .statusBacklog: "Backlog",
            .statusPlaying: "Playing",
            .statusCompleted: "Completed",
            .statusPlatinum: "Platinum",
            .statusAbandoned: "Dropped",
            .statusLabel: "Status",
            .statusFilterAll: "All",
            .filterLabel: "Filter",
            .myGamesFilterEmpty: "No game with this status.",
            .sessionsTitle: "Sessions",
            .sessionsAdd: "Log a session",
            .sessionsEmpty: "No session logged yet. Log your playthroughs to track your playtime.",
            .sessionsTotal: "Playtime",
            .sessionsCount: "sessions",
            .sessionsShowAll: "Show all",
            .sessionsShowLess: "Show less",
            .sessionEditorTitle: "New session",
            .sessionEditorEditTitle: "Edit session",
            .sessionDate: "Date",
            .sessionDuration: "Duration",
            .sessionMood: "Mood",
            .sessionNote: "Note",
            .sessionNotePlaceholder: "What you did during this session…",
            .commonSave: "Save",
            .durationHourUnit: "h",
            .durationMinuteUnit: "min",
            .moodHyped: "Great",
            .moodGood: "Good",
            .moodNeutral: "Mixed",
            .moodRough: "Rough"
        ]
    ]
}
