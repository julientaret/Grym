# Architecture — Grym

Carnet de jeu personnel pour gamers (iOS / macOS, SwiftUI, offline-first).
Chaque jeu possède un wiki personnel composé de pages et de blocs (texte, photos,
checklists, cartes annotées). Note personnelle privée de 0 à 100 par jeu.

## App

- `GrymApp.swift` — Point d'entrée `@main`, injecte le `LocalizationManager` et affiche `RootTabView`.

## Core

- `Core/Theme/Theme.swift` — Constantes du design system indépendantes du thème (spacings, font sizes, radius, durées d'animation).
- `Core/Theme/Color+Theme.swift` — Palette brute (tokens `grym*`), helper de tier de note 0–100, init `hex` et init adaptatif clair/sombre.
- `Core/Theme/AppTheme.swift` — Protocole `AppTheme` (rôles de couleur) avec défauts base Grym, enum `ThemeID`, et clé d'environnement `\.theme`.
- `Core/Theme/Themes/GrymBlueTheme.swift` — Thème par défaut (accent bleu).
- `Core/Theme/Themes/GrymVioletTheme.swift` — Variante violette ; n'écrase que ses écarts.
- `Core/Theme/ThemeManager.swift` — `ObservableObject` détenant le thème actif, le persiste (UserDefaults) et permet le switch à chaud.
- `Core/Localization/LocalizationManager.swift` — `ObservableObject` gérant la langue active (persistée en UserDefaults) et l'accès aux traductions ; injecté dans l'environnement.
- `Core/Localization/Translation.swift` — Catalogue des traductions FR/EN, enum `AppLanguage` et clés `TranslationKey`.
- `Core/Extensions/Date+Relative.swift` — Formatage relatif localisé d'une date (« il y a 2 h », « hier »).

## Core/Services/IGDB

Accès à l'API IGDB (metadata jeux), authentifiée via l'OAuth « client credentials » de Twitch.

- `IGDBConfig.swift` — Constantes d'accès : clés client (dev), endpoints token/API, marge d'expiration.
- `IGDBModels.swift` — DTO de réponse (`IGDBGame`, `IGDBCover`, `IGDBPlatform`, `IGDBTokenResponse`) + helpers de présentation (année, plateforme, URL de cover, tailles d'image).
- `IGDBError.swift` — Erreurs typées du service (`LocalizedError`).
- `IGDBService.swift` — `actor` conforme à `IGDBServiceProtocol` : gère le token (cache + refresh auto) et la recherche de jeux (`searchGames`).

## Features/Root

- `RootTabView.swift` — Navigation principale : `TabView` à trois onglets (Wikis, Explorer, Profil).

## Features/Home

Écran d'accueil (onglet Wikis) reproduisant la maquette. Données mockées tant que SwiftData n'est pas branché.

- `HomeView.swift` — Vue principale : en-tête, recherche, épinglés, activité récente, liste des wikis, sur fond dégradé.
- `HomeViewModel.swift` — `ObservableObject` exposant épinglés, activité, wikis et filtrage par recherche locale (mock).
- `Models/HomeModel.swift` — Modèles de présentation : `WikiSummary`, `ActivityEntry`, `ActivityKind`.
- `Components/HomeHeaderView.swift` — Titre « Grym », tagline et bouton d'ajout.
- `Components/HomeSearchBar.swift` — Barre de recherche locale (bind au ViewModel).
- `Components/SectionHeaderView.swift` — En-tête de section réutilisable (icône + titre + compteur).
- `Components/WikiCoverView.swift` — Cover d'un wiki (AsyncImage IGDB ou dégradé teinté de repli).
- `Components/ScoreBadgeView.swift` — Pastille de note 0–100 colorée selon le tier du thème.
- `Components/PinnedWikiCard.swift` — Carte d'un wiki épinglé.
- `Components/PinnedWikisSection.swift` — Section « Épinglés » (défilement horizontal).
- `Components/ActivityRowView.swift` — Ligne du flux d'activité récente.
- `Components/RecentActivitySection.swift` — Section « Activité récente » (carte + filets).
- `Components/WikiRowView.swift` — Ligne de la liste « Tous les wikis » (méta + stats + note).
- `Components/AllWikisSection.swift` — Section « Tous les wikis · N ».

## Features/GameSearch

Ajout d'un jeu : recherche live IGDB, présentée en sheet depuis le bouton « + » de l'accueil.

- `GameSearchView.swift` — Vue : champ de recherche + états (invite, chargement, résultats, vide, erreur) ; renvoie le jeu choisi via `onSelect`.
- `GameSearchViewModel.swift` — `ObservableObject` : debounce, appel à `IGDBService`, machine à états `State`.
- `Components/GameSearchResultRow.swift` — Ligne de résultat (cover IGDB, titre, année · plateforme).

## Features/Notes

- `NotesView.swift` — Ancien onglet Notes, carnet de jeu personnel (placeholder, plus référencé par la nav).

## Features/Search

- `SearchView.swift` — Onglet Rechercher, recherche de jeux via IGDB (placeholder à ce stade).

## Features/Profile

- `ProfileView.swift` — Onglet Profil, préférences utilisateur ; expose le choix du thème et de la langue.
- `Components/ThemePickerComponent.swift` — Sélecteur segmenté qui bascule le thème via le `ThemeManager`.
- `Components/LanguagePickerComponent.swift` — Sélecteur segmenté qui bascule la langue via le `LocalizationManager`.
