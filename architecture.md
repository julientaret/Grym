# Architecture — Grym

Carnet de jeu personnel pour gamers (iOS / macOS, SwiftUI, offline-first).
Chaque jeu possède un wiki personnel composé de pages et de blocs (texte, photos,
checklists, cartes annotées). Note personnelle privée de 0 à 100 par jeu.

## App

- `GrymApp.swift` — Point d'entrée `@main`, injecte `LocalizationManager`/`ThemeManager`, installe le `modelContainer` SwiftData (Game/Wiki/Page/Block) et affiche `RootTabView`.

## Core/Persistence

Couche de données locale (SwiftData, offline-first).

- `Game.swift` — `@Model` métadonnées d'un jeu IGDB (dé-doublonné par `igdbId`) ; cover reconstruite depuis `coverImageId`.
- `Wiki.swift` — `@Model` wiki d'un jeu : note privée, épinglage, pages ; expose des stats dérivées (blocs/photos/listes).
- `Page.swift` — `@Model` page nommée d'un wiki, contenant des blocs ordonnés.
- `Block.swift` — `@Model` bloc de contenu (type persisté en `String`, exposé via `BlockType`).
- `BlockType.swift` — Enum des types de bloc (text/photo/checklist/map).
- `WikiRepository.swift` — Écritures autour d'un `ModelContext` : création (dé-doublonnée) et suppression de wikis.
- `PreviewSampleData.swift` — Conteneur SwiftData en mémoire pré-rempli (previews, DEBUG).

## Core

- `Core/Theme/Theme.swift` — Constantes du design system indépendantes du thème (spacings, font sizes, radius, durées d'animation).
- `Core/Theme/Color+Theme.swift` — Palette brute (tokens `grym*`), helper de tier de note 0–100, teinte déterministe `grymTint`, init `hex` et init adaptatif clair/sombre.
- `Core/Theme/ScoreTier.swift` — Paliers de note (Naze→GOTY) : rang, libellé localisé et couleur.
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

## Core/Services

- `CoverStore.swift` — Stockage local des jaquettes (offline-first) : téléchargement à l'ajout, rangées dans Application Support (exclu du backup), nommées par `image_id`.

## Features/Root

- `RootTabView.swift` — Navigation principale : `TabView` à trois onglets (Wikis, Mes jeux, Profil).

## Features/Home

Écran d'accueil (onglet Wikis) — **dashboard** : épinglés et activité récente. La liste complète vit dans « Mes jeux ».

- `HomeView.swift` — Vue principale : en-tête, épinglés, activité récente, état vide de dashboard, sur fond dégradé. Ouvre la recherche via « + ».
- `HomeViewModel.swift` — `ObservableObject` : charge épinglés + total depuis SwiftData (`load(context:)`) ; `isDashboardEmpty`.
- `Models/HomeModel.swift` — Modèles de présentation : `WikiSummary` (mapping depuis `Wiki`), `ActivityEntry`, `ActivityKind`.
- `Components/HomeHeaderView.swift` — Titre « Grym », tagline et bouton d'ajout.
- `Components/HomeSearchBar.swift` — Barre de recherche locale (actuellement masquée, conservée pour plus tard).
- `Components/SectionHeaderView.swift` — En-tête de section réutilisable (icône + titre + compteur).
- `Components/WikiCoverView.swift` — Cover d'un wiki : jaquette locale (offline) sinon CDN IGDB sinon dégradé teinté. Prend un `image_id`.
- `Components/ScoreBadgeView.swift` — Pastille de note 0–100 colorée selon le tier du thème.
- `Components/PinnedWikiCard.swift` — Carte d'un wiki épinglé.
- `Components/PinnedWikisSection.swift` — Section « Épinglés » (défilement horizontal).
- `Components/ActivityRowView.swift` — Ligne du flux d'activité récente.
- `Components/RecentActivitySection.swift` — Section « Activité récente » (carte + filets).
- `Components/WikiRowView.swift` — Ligne de jeu réutilisable (cover, méta, stats blocs/photos/listes, note). Utilisée aussi par « Mes jeux ».
- `Components/AllWikisSection.swift` — Section liste de wikis avec compteur et état vide.

## Features/MyGames

Onglet « Mes jeux » : liste complète des jeux ajoutés.

- `MyGamesView.swift` — `NavigationStack` : liste des wikis (`WikiRowView`), compteur, état vide, suppression par menu contextuel, navigation vers `WikiDetailView`.
- `MyGamesViewModel.swift` — `ObservableObject` : charge les wikis (`load`), suppression via `WikiRepository` (`delete`).

## Features/WikiDetail

Détail d'un wiki : édition directe du modèle via `@Bindable` (écart MVVM justifié) ; mutations structurelles via `WikiRepository`.

- `WikiDetailView.swift` — Assemble en-tête, note personnelle et pages ; épinglage, réglage du score, ajout de page.
- `Components/WikiDetailHeader.swift` — Cover, titre, méta, bouton épingler et ligne de stats.
- `Components/WikiScoreCard.swift` — Carte « Note personnelle » : score, palier et slider 0–100 à dégradé de tiers (drag par translation).
- `Components/PageRowView.swift` — Ligne d'une page (icône, titre, nombre de blocs).

## Features/GameSearch

Ajout d'un jeu : recherche live IGDB, présentée en sheet depuis le bouton « + » de l'accueil.

- `GameSearchView.swift` — Vue : champ de recherche + états (invite, chargement, résultats, vide, erreur) ; à la sélection, persiste le wiki via `WikiRepository` puis referme.
- `GameSearchViewModel.swift` — `ObservableObject` : debounce, appel à `IGDBService`, machine à états `State`.
- `Components/GameSearchResultRow.swift` — Ligne de résultat (cover IGDB, titre, année · plateforme).

## Features/Profile

- `ProfileView.swift` — Onglet Profil, préférences utilisateur ; expose le choix du thème et de la langue.
- `Components/ThemePickerComponent.swift` — Sélecteur segmenté qui bascule le thème via le `ThemeManager`.
- `Components/LanguagePickerComponent.swift` — Sélecteur segmenté qui bascule la langue via le `LocalizationManager`.
