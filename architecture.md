# Architecture — Grym

Carnet de jeu personnel pour gamers (iOS / macOS, SwiftUI, offline-first).
Chaque jeu possède un carnet composé de pages — nommées « wikis » côté UI — et de blocs (texte, photos,
checklists, cartes annotées). Note personnelle privée de 0 à 100 par jeu.

## App

- `GrymApp.swift` — Point d'entrée `@main`, injecte `LocalizationManager`/`ThemeManager`, installe le `modelContainer` SwiftData (Game/Wiki/Page/Block) et affiche `RootTabView`.

## Core/Premium

- `PremiumManager.swift` — `ObservableObject` StoreKit 2 : charge le produit (`com.applemousse.grym.premium`, achat unique), achat/restauration, observe les transactions et expose `isPremium` (droit StoreKit mis en cache UserDefaults) + limite gratuite (`freeGameLimit = 10`).

## Configuration (hors Swift)

- `StoreKit/Grym.storekit` — Configuration StoreKit locale (produit premium, prix) pour tester l'achat en simulateur via le scheme.
- `Grym.xcodeproj/xcshareddata/xcschemes/Grym.xcscheme` — Scheme partagé référençant la config StoreKit (l'achat local ne s'active qu'au lancement via Xcode/scheme).

## Core/Persistence

Couche de données locale (SwiftData, offline-first).

- `Game.swift` — `@Model` métadonnées d'un jeu IGDB (dé-doublonné par `igdbId`) ; cover reconstruite depuis `coverImageId`. Porte aussi les médias IGDB (`screenshotImageIds`, `artworkImageIds`, `mediaFetchedAt`) et en dérive le bandeau (`heroImageId`) et la galerie (`galleryImageIds`).
- `Wiki.swift` — `@Model` wiki d'un jeu : note privée (datée par `scoreUpdatedAt`), épinglage, pages ; expose des stats dérivées (blocs/photos/listes).
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
- `Core/Theme/AppTheme.swift` — Protocole `AppTheme` (rôles de couleur) avec défauts base Grym, enum `ThemeID`, et clé d'environnement `\.theme`.
- `Core/Theme/Themes/GrymBlueTheme.swift` — Thème par défaut (accent bleu).
- `Core/Theme/Themes/GrymVioletTheme.swift` — Variante violette ; n'écrase que ses écarts.
- `Core/Theme/ThemeManager.swift` — `ObservableObject` détenant le thème actif, le persiste (UserDefaults) et permet le switch à chaud.
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

- `HomeView.swift` — Vue principale : en-tête, épinglés, activité récente, état vide de dashboard, sur fond dégradé. Ouvre la recherche via « + ».
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

- `MyGamesView.swift` — `NavigationStack` : liste des wikis (`WikiRowView`), compteur, état vide, suppression par menu contextuel, navigation vers `WikiDetailView`.
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

- `WikiDetailView.swift` — `List` : bandeau illustré, en-tête, note personnelle, galerie de médias et pages avec 3 modes d'affichage (Liste/Onglets/Cartes) ; épinglage, score, ajout/réorganisation (drag & drop en mode Liste)/suppression de pages.
- `WikiMediaViewModel.swift` — Charge les médias IGDB du jeu à l'ouverture du wiki (si jamais récupérés) et les persiste sur `Game` ; erreurs silencieuses (médias décoratifs, réessai à la prochaine ouverture).
- `Components/WikiDetailHeader.swift` — Cover, titre, méta, bouton épingler et ligne de stats.
- `Components/WikiHeroBanner.swift` — Bandeau illustré pleine largeur en tête du wiki : file jusqu'au haut de l'écran (la barre de navigation se pose dessus), fondu vers le bas par un masque (se raccorde à n'importe quel thème).
- `Components/WikiMediaGallery.swift` — Galerie horizontale des captures/illustrations IGDB ; vignettes en lazy loading, appui pour ouvrir la visionneuse.
- `Components/MediaViewerView.swift` — Visionneuse plein écran paginée des médias (1080p sur fond noir). Écart MVVM justifié : aucune logique métier.
- `Components/PageCardView.swift` — Carte de page (mode Cartes).
- `Components/PageTabsView.swift` — Mode Onglets : chips de pages + aperçu léger (résumé des blocs) de la page sélectionnée.
- `Components/WikiScoreCard.swift` — Carte « Note personnelle » : score, palier et slider 0–100 à dégradé de tiers (drag par translation).
- `Components/PageRowView.swift` — Ligne d'une page (icône, titre, nombre de blocs).

## Features/Premium

- `PremiumUpgradeView.swift` — Prompt d'upgrade (avantages + prix localisé StoreKit) : achat et restauration via `PremiumManager`, présenté à l'atteinte de la limite gratuite.

## Features/GameSearch

Ajout d'un jeu : recherche live IGDB, présentée en sheet depuis le bouton « + » de l'accueil.

- `GameSearchView.swift` — Vue : champ de recherche + états (invite, chargement, résultats, vide, erreur) ; à la sélection, persiste le wiki via `WikiRepository` puis referme.
- `GameSearchViewModel.swift` — `ObservableObject` : debounce, appel à `IGDBService`, machine à états `State`.
- `Components/GameSearchResultRow.swift` — Ligne de résultat (cover IGDB, titre, année · plateforme).

## Features/Profile

- `ProfileView.swift` — Onglet Profil, préférences utilisateur ; expose le choix du thème et de la langue.
- `Components/ThemePickerComponent.swift` — Sélecteur segmenté qui bascule le thème via le `ThemeManager`.
- `Components/LanguagePickerComponent.swift` — Sélecteur segmenté qui bascule la langue via le `LocalizationManager`.
