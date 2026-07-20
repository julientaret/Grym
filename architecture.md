# Architecture — Grym

Carnet de jeu personnel pour gamers (iOS / macOS, SwiftUI, offline-first).
Chaque jeu possède un carnet composé de pages — nommées « wikis » côté UI — et de blocs (texte, photos,
checklists, cartes annotées). Note personnelle privée de 0 à 100 par jeu.

## App

- `GrymApp.swift` — Point d'entrée `@main`, injecte `LocalizationManager`/`ThemeManager`/`PremiumManager`/`PreferencesManager`, installe le `modelContainer` SwiftData (Game/Wiki/Page/Block) et affiche `RootTabView`.

## Core/Components

- `EmptyStateView.swift` — État vide réutilisable (Accueil, Mes jeux) : badge illustré, titre, message, étapes « quoi faire » et appel à l'action optionnel.

## Core/Preferences

- `WikiPagesMode.swift` — Mode d'affichage des pages d'un wiki (liste / onglets / cartes) : clé de traduction et icône.
- `PreferencesManager.swift` — `ObservableObject` détenant les préférences d'affichage globales (mode des pages de wiki), persistées en UserDefaults.

## Core/Premium

- `PremiumManager.swift` — `ObservableObject` StoreKit 2 : charge le produit (`com.applemousse.grym.premium`, achat unique), achat/restauration, observe les transactions et expose `hasStoreEntitlement` (mis en cache UserDefaults) + `isPremium` effectif (en DEBUG, `debugPremiumOverride` le force) et la limite gratuite (`freeGameLimit = 10`).

## Configuration (hors Swift)

- `StoreKit/Grym.storekit` — Configuration StoreKit locale (produit premium, prix) pour tester l'achat en simulateur via le scheme.
- `Grym.xcodeproj/xcshareddata/xcschemes/Grym.xcscheme` — Scheme partagé référençant la config StoreKit (l'achat local ne s'active qu'au lancement via Xcode/scheme).

## Core/Persistence

Couche de données locale (SwiftData, offline-first).

- `Game.swift` — `@Model` métadonnées d'un jeu IGDB (dé-doublonné par `igdbId`) ; cover reconstruite depuis `coverImageId`. Porte aussi les médias IGDB (`screenshotImageIds`, `artworkImageIds`, `mediaFetchedAt`) et en dérive l'image du bandeau (`heroImageId`).
- `Wiki.swift` — `@Model` wiki d'un jeu : note privée (datée par `scoreUpdatedAt`), épinglage, pages ; expose des stats dérivées (blocs/photos/listes) et `photoFileNames` (toutes les photos du wiki, pour la galerie du détail).
- `Page.swift` — `@Model` page nommée d'un wiki (« wiki » côté UI), contenant des blocs ordonnés ; `createdAt` alimente le flux d'activité de l'accueil.
- `Block.swift` — `@Model` bloc de contenu (type persisté en `String`, exposé via `BlockType`).
- `BlockType.swift` — Enum des types de bloc (text/photo/checklist/map).
- `BlockContent.swift` — Encodage du contenu des blocs : texte brut (`.text`), JSON `ChecklistContent` (`.checklist`), `PhotoContent` (`.photo`) ou `MapContent` (`.map`, image + pins) ; accès via `Block.checklist` / `Block.photos` / `Block.map`.
- `WikiRepository.swift` — Écritures autour d'un `ModelContext` : création (dé-doublonnée) et suppression de wikis ; `updateScore` date les changements de note, `touch` marque une simple modification.
- `PreviewSampleData.swift` — Conteneur SwiftData en mémoire pré-rempli (previews, DEBUG).

## Core

- `Core/Theme/Theme.swift` — Constantes du design system indépendantes du thème (spacings, font sizes, radius, durées d'animation).
- `Core/Theme/Color+Theme.swift` — Palette brute (tokens `grym*`), helper de tier de note 0–100, teinte déterministe `grymTint`, init `hex` et init adaptatif clair/sombre.
- `Core/Theme/ScoreTier.swift` — Paliers de note (Naze→GOTY) : rang, libellé localisé et couleur.
- `Core/Theme/AppTheme.swift` — Protocole `AppTheme` (rôles de couleur, dont `pageAccents`) avec défauts base Grym, enum `ThemeID` (+ `requiresPremium`, thème gratuit), et clé d'environnement `\.theme`.
- `Core/Theme/Themes/GrymBlueTheme.swift` — Thème par défaut et gratuit : accent cyan sur base bleu nuit (fonds, surface et halo propres).
- `Core/Theme/Themes/GrymVioletTheme.swift` — Variante violette (premium) sur la base violette historique.
- `Core/Theme/Themes/GrymEmeraldTheme.swift` — Variante émeraude (premium) : accent #2CD4A0 sur base vert profond.
- `Core/Theme/Themes/GrymMagentaTheme.swift` — Variante magenta (premium) : accent #E85C9E sur base prune.
- `Core/Theme/ThemeManager.swift` — `ObservableObject` détenant le thème actif, le persiste (UserDefaults), permet le switch à chaud et repasse au thème gratuit si le droit premium est perdu (`enforceEntitlement`).
- `Core/Localization/LocalizationManager.swift` — `ObservableObject` gérant la langue active (persistée en UserDefaults) et l'accès aux traductions ; injecté dans l'environnement.
- `Core/Localization/Translation.swift` — Catalogue des traductions FR/EN, enum `AppLanguage` et clés `TranslationKey`.
- `Core/Extensions/Date+Relative.swift` — Formatage relatif localisé d'une date (« il y a 2 h », « hier »).
- `Core/Extensions/View+GrymListRow.swift` — Style de ligne de `List` transparent (`grymBlockRow`, et `grymFullWidthRow` pour les contenus bord à bord) pour garder l'apparence carte avec le drag & drop natif.

## Core/Services/IGDB

Accès à l'API IGDB (metadata jeux), authentifiée via l'OAuth « client credentials » de Twitch.

- `IGDBConfig.swift` — Constantes d'accès : clés client (dev), endpoints token/API, marge d'expiration.
- `IGDBModels.swift` — DTO de réponse (`IGDBGame`, `IGDBImage`, `IGDBPlatform`, `IGDBTokenResponse`, `IGDBGameMediaResponse`/`IGDBGameMedia`) + helpers de présentation (année, plateforme, URL de cover, tailles d'image).
- `IGDBError.swift` — Erreurs typées du service (`LocalizedError`).
- `IGDBService.swift` — `actor` conforme à `IGDBServiceProtocol` : gère le token (cache + refresh auto), la recherche de jeux (`searchGames`) et les médias d'un jeu (`gameMedia`, appel séparé car les images alourdissent la réponse).

## Core/Services

- `CoverStore.swift` — Stockage local des jaquettes (offline-first) : téléchargement à l'ajout, rangées dans Application Support (exclu du backup), nommées par `image_id`.
- `ImageStore.swift` — Stockage local des images de blocs photo : ré-encodage JPEG downscalé (max 1600 px), rangées dans Application Support (exclu du backup).

## Features/Root

- `RootTabView.swift` — Navigation principale : `TabView` à trois onglets (Accueil, Mes jeux, Profil).

## Features/Home

Écran d'accueil (onglet Wikis) — **dashboard** : épinglés et activité récente. La liste complète vit dans « Mes jeux ».

- `HomeView.swift` — Vue principale : en-tête, épinglés, activité récente, sur fond dégradé. Deux états vides via `EmptyStateView` (onboarding + ajout de jeu si aucun jeu, explication de l'épinglage sinon).
- `HomeViewModel.swift` — `ObservableObject` : charge épinglés + total depuis SwiftData (`load(context:localization:)`) et construit le flux d'activité récente (wikis créés + notes modifiées, fusionnés et triés, 8 max) ; `isDashboardEmpty`.
- `Models/HomeModel.swift` — Modèles de présentation : `WikiSummary` (mapping depuis `Wiki`), `ActivityEntry` (jaquette incluse), `ActivityKind`.
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

- `MyGamesView.swift` — `NavigationStack` : liste des wikis (`WikiRowView`), compteur, état vide illustré (`EmptyStateView` + CTA d'ajout, mention du palier gratuit hors premium), suppression par menu contextuel, navigation vers `WikiDetailView` (le wiki créé depuis la recherche est poussé automatiquement à la fermeture de la sheet).
- `MyGamesViewModel.swift` — `ObservableObject` : charge les wikis (`load`), suppression via `WikiRepository` (`delete`).

## Features/PageDetail

Éditeur d'une page : titre éditable et flux de blocs (texte, checklist ; photo/carte à venir).

- `PageDetailView.swift` — `List` : titre et blocs ; ajout (menu de type), réorganisation (drag & drop via EditButton) et suppression de blocs ; sauvegarde à la sortie.
- `Components/TextBlockView.swift` — Bloc texte libre, lié à `Block.content`.
- `Components/ChecklistBlockView.swift` — Bloc checklist : titre, items cochables, progression.
- `Components/PhotoBlockView.swift` — Bloc photo : galerie de miniatures locales, ajout via PhotosPicker, suppression, ouverture plein écran au tap via QuickLook natif (`.quickLookPreview`, zoom/pan/partage/swipe).
- `MapEditorView.swift` — Éditeur plein écran d'une carte : image + pins (ajout au tap, drag, renommage/suppression).
- `Components/MapBlockView.swift` — Bloc carte : aperçu (image + pins) ou invite d'ajout ; ouvre l'éditeur au tap.
- `Components/AnnotatedMapView.swift` — Affichage image + pins (coordonnées relatives) ; mode lecture seule ou édition. Inclut `MapPinMarker`.
- `Components/AddBlockButton.swift` — Bouton + menu de choix du type de bloc (texte / checklist / photo / carte).

## Features/WikiDetail

Détail d'un wiki : édition directe du modèle via `@Bindable` (écart MVVM justifié) ; mutations structurelles via `WikiRepository`.

- `WikiDetailView.swift` — `List` : bandeau illustré, en-tête, note personnelle, galerie des photos de l'utilisateur (aperçu QuickLook) et pages selon le mode d'affichage global choisi dans le Profil (Liste/Onglets/Cartes) ; épinglage, score, ajout/réorganisation (drag & drop en mode Liste)/suppression de pages.
- `WikiMediaViewModel.swift` — Charge les médias IGDB du jeu à l'ouverture du wiki (si jamais récupérés) et les persiste sur `Game` ; alimente le bandeau. Erreurs silencieuses (décoratif, réessai à la prochaine ouverture).
- `Components/WikiDetailHeader.swift` — Cover, titre, méta, bouton épingler et ligne de stats.
- `Components/WikiHeroBanner.swift` — Bandeau illustré pleine largeur en tête du wiki : file jusqu'au haut de l'écran (la barre de navigation se pose dessus), fondu vers le bas par un masque (se raccorde à n'importe quel thème).
- `Components/WikiMediaGallery.swift` — Galerie horizontale des photos ajoutées par l'utilisateur (blocs photo du wiki) ; vignettes locales (`ImageStore`), appui pour ouvrir l'aperçu. Masquée si aucune photo.
- `Components/PageCardView.swift` — Carte de page (mode Cartes).
- `Components/PageTabsView.swift` — Mode Onglets : chips de pages + aperçu léger (résumé des blocs) de la page sélectionnée.
- `Components/WikiScoreCard.swift` — Carte « Note personnelle » : score, palier et slider 0–100 à dégradé de tiers (drag par translation), replié par défaut derrière un en-tête cliquable.
- `Components/PageRowView.swift` — Ligne d'une page (icône, titre, nombre de blocs).

## Features/Premium

- `PremiumUpgradeView.swift` — Prompt d'upgrade (avantages + prix localisé StoreKit) : achat et restauration via `PremiumManager`, présenté à l'atteinte de la limite gratuite.

## Features/GameSearch

Ajout d'un jeu : recherche live IGDB, présentée en sheet depuis le bouton « + » de l'accueil.

- `GameSearchView.swift` — Vue : champ de recherche + états (invite, chargement, résultats, vide, erreur) ; à la sélection, persiste le wiki via `WikiRepository`, le remonte via `onSelect(Wiki)` puis referme.
- `GameSearchViewModel.swift` — `ObservableObject` : debounce, appel à `IGDBService`, machine à états `State`.
- `Components/GameSearchResultRow.swift` — Ligne de résultat (cover IGDB, titre, année · plateforme).

## Features/Profile

- `ProfileView.swift` — Onglet Profil : fond dégradé Grym et cartes de réglages (Apparence : thème + langue ; Affichage : mode des wikis ; Développement : simulation du premium, DEBUG seulement).
- `Components/ProfileHeaderView.swift` — En-tête du profil (titre + sous-titre), aligné sur le style de l'accueil.
- `Components/ProfileSectionCard.swift` — Carte de section générique : `SectionHeaderView` + contenu sur surface translucide.
- `Components/ProfileSettingRow.swift` — Ligne de réglage : intitulé, contrôle et texte d'aide optionnel.
- `Components/ThemePickerComponent.swift` — Grille de vignettes de thèmes ; applique le thème via le `ThemeManager`, ou ouvre `PremiumUpgradeView` si le thème est verrouillé.
- `Components/ThemeSwatchView.swift` — Vignette d'aperçu d'un thème (dégradé, halo, surface, accents) avec états sélectionné / verrouillé.
- `Components/DebugPremiumToggle.swift` — Interrupteur de simulation du premium, compilé uniquement en DEBUG (`#if DEBUG`).
- `Components/LanguagePickerComponent.swift` — Sélecteur segmenté qui bascule la langue via le `LocalizationManager`.
- `Components/WikiModePickerComponent.swift` — Sélecteur segmenté du mode d'affichage des wikis via le `PreferencesManager`, suivi de l'aperçu du rendu.
- `Components/WikiModePreviewComponent.swift` — Aperçu miniature schématique du mode choisi (deux wikis factices), en Liste / Onglets / Cartes.
