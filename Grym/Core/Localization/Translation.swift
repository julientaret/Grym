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
    case profileLanguageLabel
    case profileSubtitle
    case profileAppearanceSection
    case profileDisplaySection
    case profileWikiModeLabel
    case profileWikiModeHint
    case profileWikiModeSampleFirst
    case profileWikiModeSampleSecond
    case themeGrymBlue
    case themeGrymViolet
    // Home
    case appTagline
    case homeSearchPlaceholder
    case homePinned
    case homeRecentActivity
    case homeActivityNewWiki
    case homeActivityScore
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
    case homeDashboardEmpty
    case tabMyGames
    case myGamesTitle
    case commonDelete
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
    case photoAdd
    case mapAddImage
    case mapReplaceImage
    case mapEmptyHint
    case mapPinLabelPlaceholder
    case mapNoImageHint
    case commonDone
    case textBlockPlaceholder
    case checklistTitlePlaceholder
    case checklistAddItem
    case checklistItemPlaceholder
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
            .profileLanguageLabel: "Langue",
            .profileSubtitle: "Personnalisez votre expérience",
            .profileAppearanceSection: "Apparence",
            .profileDisplaySection: "Affichage",
            .profileWikiModeLabel: "Affichage des wikis",
            .profileWikiModeHint: "Le même réglage s'applique à tous vos jeux.",
            .profileWikiModeSampleFirst: "Quêtes",
            .profileWikiModeSampleSecond: "Builds",
            .themeGrymBlue: "Bleu",
            .themeGrymViolet: "Violet",
            .appTagline: "Votre pense-bête vidéoludique",
            .homeSearchPlaceholder: "Rechercher un wiki ou un jeu…",
            .homePinned: "Épinglés",
            .homeRecentActivity: "Activité récente",
            .homeActivityNewWiki: "Nouveau wiki",
            .homeActivityScore: "Note mise à jour",
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
            .homeDashboardEmpty: "Tes jeux épinglés et ton activité récente apparaîtront ici.",
            .tabMyGames: "Mes jeux",
            .myGamesTitle: "Mes jeux",
            .commonDelete: "Supprimer",
            .wikiNoteTitle: "NOTE PERSONNELLE",
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
            .pageEmptyBlocks: "Wiki vide.\nAjoute un premier bloc ci-dessous.",
            .addBlock: "Ajouter un bloc",
            .blockTypeText: "Texte",
            .blockTypeChecklist: "Checklist",
            .blockTypePhoto: "Photo",
            .blockTypeMap: "Carte",
            .photoAdd: "Ajouter des photos",
            .mapAddImage: "Ajouter une carte",
            .mapReplaceImage: "Remplacer",
            .mapEmptyHint: "Touche la carte pour ajouter un repère.",
            .mapPinLabelPlaceholder: "Nom du repère",
            .mapNoImageHint: "Aucune carte. Ajoute une image à annoter.",
            .commonDone: "Terminé",
            .textBlockPlaceholder: "Écris ici…",
            .checklistTitlePlaceholder: "Titre de la liste",
            .checklistAddItem: "Ajouter un élément",
            .checklistItemPlaceholder: "Élément"
        ],
        .english: [
            .tabProfile: "Profile",
            .tabHome: "Home",
            .profileThemeLabel: "Theme",
            .profileLanguageLabel: "Language",
            .profileSubtitle: "Make the app yours",
            .profileAppearanceSection: "Appearance",
            .profileDisplaySection: "Display",
            .profileWikiModeLabel: "Wikis display",
            .profileWikiModeHint: "The same setting applies to all your games.",
            .profileWikiModeSampleFirst: "Quests",
            .profileWikiModeSampleSecond: "Builds",
            .themeGrymBlue: "Blue",
            .themeGrymViolet: "Violet",
            .appTagline: "Your video game notebook",
            .homeSearchPlaceholder: "Search a wiki or a game…",
            .homePinned: "Pinned",
            .homeRecentActivity: "Recent activity",
            .homeActivityNewWiki: "New wiki",
            .homeActivityScore: "Score updated",
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
            .homeDashboardEmpty: "Your pinned games and recent activity will show up here.",
            .tabMyGames: "My games",
            .myGamesTitle: "My games",
            .commonDelete: "Delete",
            .wikiNoteTitle: "PERSONAL SCORE",
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
            .pageEmptyBlocks: "Empty wiki.\nAdd a first block below.",
            .addBlock: "Add a block",
            .blockTypeText: "Text",
            .blockTypeChecklist: "Checklist",
            .blockTypePhoto: "Photo",
            .blockTypeMap: "Map",
            .photoAdd: "Add photos",
            .mapAddImage: "Add a map",
            .mapReplaceImage: "Replace",
            .mapEmptyHint: "Tap the map to add a pin.",
            .mapPinLabelPlaceholder: "Pin name",
            .mapNoImageHint: "No map yet. Add an image to annotate.",
            .commonDone: "Done",
            .textBlockPlaceholder: "Write here…",
            .checklistTitlePlaceholder: "List title",
            .checklistAddItem: "Add an item",
            .checklistItemPlaceholder: "Item"
        ]
    ]
}
