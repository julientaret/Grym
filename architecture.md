# Architecture — Grym

Carnet de jeu personnel pour gamers (iOS / macOS, SwiftUI, offline-first).
Chaque jeu possède un carnet composé de pages — nommées « wikis » côté UI — et de blocs (texte, photos,
checklists, cartes annotées). Note personnelle privée de 0 à 100 par jeu, statut de progression
(à jouer → platiné) et journal de sessions de jeu.

## App

- `GrymApp.swift` — Point d'entrée `@main`, injecte `LocalizationManager`/`ThemeManager`/`PremiumManager`/`PreferencesManager`/`AppRouter`, installe le `modelContainer` SwiftData (Game/Wiki/Page/Block/PlaySession) et affiche `RootTabView`.

## Core/Navigation

- `AppRouter.swift` — `ObservableObject` transverse : onglet actif (`RootTab`) et cible en attente (`pendingTarget`) demandée depuis l'extérieur (résultat Spotlight) ; `open(_:)` bascule sur « Mes jeux ».

## Core/Components

- `BannerHeaderView.swift` — Bannière illustrée d'en-tête d'onglet (Accueil, Mes jeux) : image rognée à la largeur de la vue, assombrie et fondue en alpha vers le bas, avec contenu libre superposé.
- `GameStatusBadge.swift` — Pastille de statut de progression (icône + libellé colorés), variante compacte pour les listes denses ; partagée entre le détail d'un wiki et « Mes jeux ».
- `EmptyStateView.swift` — État vide réutilisable (Accueil, Mes jeux) : badge illustré, titre, message, étapes « quoi faire » et appel à l'action optionnel.

## Core/Preferences

- `WikiPagesMode.swift` — Mode d'affichage des pages d'un wiki (liste / onglets / cartes) : clé de traduction et icône.
- `GameSortOption.swift` — Critère de tri de « Mes jeux » (récent / titre / note / date de sortie / temps de jeu) : clé de traduction et icône.
- `PreferencesManager.swift` — `ObservableObject` détenant les préférences d'affichage globales (mode des pages de wiki), persistées en UserDefaults.

## Core/Premium

- `PremiumManager.swift` — `ObservableObject` StoreKit 2 : charge le produit (`com.applemousse.grym.premium`, achat unique), achat/restauration, observe les transactions et expose `hasStoreEntitlement` (mis en cache UserDefaults) + `isPremium` effectif (en DEBUG, `debugPremiumOverride` le force) et la limite gratuite (`freeGameLimit = 10`).

## Configuration (hors Swift)

- `StoreKit/Grym.storekit` — Configuration StoreKit locale (produit premium, prix) pour tester l'achat en simulateur via le scheme.
- `Grym.xcodeproj/xcshareddata/xcschemes/Grym.xcscheme` — Scheme partagé référençant la config StoreKit (l'achat local ne s'active qu'au lancement via Xcode/scheme).

## Core/Persistence

Couche de données locale (SwiftData, offline-first).

- `Game.swift` — `@Model` métadonnées d'un jeu IGDB (dé-doublonné par `igdbId`) ; cover reconstruite depuis `coverImageId`. Porte aussi les médias IGDB (`screenshotImageIds`, `artworkImageIds`, `mediaFetchedAt`) et en dérive l'image du bandeau (`heroImageId`).
- `Wiki.swift` — `@Model` wiki d'un jeu : note privée (datée par `scoreUpdatedAt`), statut de progression (`statusRaw`/`statusUpdatedAt`, exposé via `status`), épinglage, pages et sessions ; expose des stats dérivées (blocs/photos/listes), `photoFileNames` (galerie du détail) et le cumul de temps de jeu (`totalPlayMinutes`, `sortedSessions`, `lastSessionDate`).
- `GameStatus.swift` — Enum du statut de progression (aucun / à jouer / en cours / terminé / platiné / abandonné) : clé de traduction, icône et couleur déclinée light/dark.
- `PlaySession.swift` — `@Model` session de jeu consignée : date, durée en minutes, ressenti (`moodRaw`, exposé via `mood`) et note libre ; fournit les durées proposées à l'éditeur.
- `SessionMood.swift` — Enum du ressenti d'une session (excellent / bien / mitigé / galère) : clé de traduction, icône et couleur.
- `WikiTemplate.swift` — Modèles de démarrage d'un carnet (RPG, souls-like, monde ouvert, roguelike) : nom, description, icône et pages à créer avec leurs blocs d'amorce.
- `WikiLink.swift` — Liens internes `[[Titre de page]]` : analyse du balisage, rendu en `AttributedString` cliquable (URL interne `grym://page?title=`), et extensions `Wiki.page(titled:)` / `Page.linkedTitles` / `Page.backlinks`.
- `Page.swift` — `@Model` page nommée d'un wiki (« wiki » côté UI), contenant des blocs ordonnés ; `createdAt` alimente le flux d'activité de l'accueil.
- `Block.swift` — `@Model` bloc de contenu (type persisté en `String`, exposé via `BlockType`).
- `BlockType.swift` — Enum des types de bloc (text/photo/checklist/map).
- `BlockContent.swift` — Encodage du contenu des blocs : texte brut (`.text`), JSON `ChecklistContent` (`.checklist`), `PhotoContent` (`.photo`) ou `MapContent` (`.map`, image + pins) ; accès via `Block.checklist` / `Block.photos` / `Block.map`.
- `WikiRepository.swift` — Écritures autour d'un `ModelContext` : création (dé-doublonnée) et suppression de wikis ; `updateScore` date les changements de note, `updateStatus` ceux de statut, `addSession`/`delete(_ session:)` gèrent le journal, `apply(template:to:titleFor:)` déroule un modèle de démarrage, `touch` marque une simple modification.
- `PreviewSampleData.swift` — Conteneur SwiftData en mémoire pré-rempli (previews, DEBUG).

## Core

- `Core/Theme/Theme.swift` — Constantes du design system indépendantes du thème (spacings, font sizes, radius, dimensions, durées d'animation).
- `Core/Theme/Color+Theme.swift` — Palette brute (tokens `grym*`), helper de tier de note 0–100, teinte déterministe `grymTint`, init `hex` et init adaptatif clair/sombre.
- `Core/Theme/ScoreTier.swift` — Paliers de note (Naze→GOTY) : rang, libellé localisé et couleur.
- `Core/Theme/AppTheme.swift` — Protocole `AppTheme` (rôles de couleur, dont `pageAccents`) avec défauts base Grym, enum `ThemeID` (+ `requiresPremium`, thème gratuit, `nameKey`/`taglineKey` — noms clins d'œil au vocabulaire du jeu vidéo), et clé d'environnement `\.theme`.
- `Core/Theme/Themes/GrymBlueTheme.swift` — Thème par défaut et gratuit : accent cyan sur base bleu nuit (fonds, surface et halo propres).
- `Core/Theme/Themes/GrymVioletTheme.swift` — Variante violette (premium) sur la base violette historique.
- `Core/Theme/Themes/GrymEmeraldTheme.swift` — Variante émeraude (premium) : accent #2CD4A0 sur base vert profond.
- `Core/Theme/Themes/GrymMagentaTheme.swift` — Variante magenta (premium) : accent #E85C9E sur base prune.
- `Core/Theme/ThemeManager.swift` — `ObservableObject` détenant le thème actif, le persiste (UserDefaults), permet le switch à chaud et repasse au thème gratuit si le droit premium est perdu (`enforceEntitlement`).
- `Core/Localization/LocalizationManager.swift` — `ObservableObject` gérant la langue active (persistée en UserDefaults) et l'accès aux traductions ; injecté dans l'environnement.
- `Core/Localization/Translation.swift` — Catalogue des traductions FR/EN, enum `AppLanguage` et clés `TranslationKey`.
- `Core/Extensions/Date+Relative.swift` — Formatage relatif localisé d'une date (« il y a 2 h », « hier »).
- `Core/Extensions/Int+Playtime.swift` — Formate une durée en minutes en libellé lisible (« 2 h 30 », « 45 min »), unités fournies par l'appelant (localisées).
- `Core/Extensions/View+SelectAllOnFocus.swift` — Modifieur `selectAllOnFocus(isArmed:)` : sélectionne le texte du prochain champ prenant le focus (via la notification UIKit d'entrée en édition), pour écraser une valeur par défaut.
- `Core/Extensions/View+GrymListRow.swift` — Style de ligne de `List` transparent (`grymBlockRow`, et `grymFullWidthRow` pour les contenus bord à bord) pour garder l'apparence carte avec le drag & drop natif.

## Core/Services/IGDB

Accès à l'API IGDB (metadata jeux), authentifiée via l'OAuth « client credentials » de Twitch.

- `IGDBConfig.swift` — Constantes d'accès : clés client (dev), endpoints token/API, marge d'expiration.
- `IGDBModels.swift` — DTO de réponse (`IGDBGame`, `IGDBImage`, `IGDBTokenResponse`, `IGDBGameMediaResponse`/`IGDBGameMedia`) + helpers de présentation (année, URL de cover, tailles d'image).
- `IGDBError.swift` — Erreurs typées du service (`LocalizedError`).
- `IGDBService.swift` — `actor` conforme à `IGDBServiceProtocol` : gère le token (cache + refresh auto), la recherche de jeux (`searchGames`) et les médias d'un jeu (`gameMedia`, appel séparé car les images alourdissent la réponse).

## Core/Services

- `CoverStore.swift` — Stockage local des jaquettes (offline-first) : téléchargement à l'ajout, rangées dans Application Support (exclu du backup), nommées par `image_id`.
- `SpotlightIndexer.swift` — Indexation CoreSpotlight des jeux et des wikis (identifiants lisibles `game:<igdbId>` / `page:<igdbId>:<titre>`), réindexation complète au lancement et au passage en arrière-plan ; `target(for:context:)` résout un résultat système en destination applicative.
- `ImageStore.swift` — Stockage local des images de blocs photo : ré-encodage JPEG downscalé (max 1600 px), rangées dans Application Support (exclu du backup).

## Features/Root

- `RootTabView.swift` — Navigation principale : `TabView` à trois onglets (Accueil, Mes jeux, Profil), sélection pilotée par l'`AppRouter` ; déclenche l'indexation Spotlight et ouvre les résultats de la recherche système (`onContinueUserActivity`).

## Features/Search

Recherche globale hors ligne dans toute la collection, présentée en sheet depuis l'accueil.

- `GlobalSearchView.swift` — `NavigationStack` + `.searchable` : résultats groupés par section, états invite / vide, ouverture directe du wiki ou de la page trouvée.
- `GlobalSearchViewModel.swift` — `ObservableObject` : parcours en mémoire des wikis (titres de jeu, titres de page, notes, items de checklist, repères de carte), extraits centrés sur l'occurrence, plafond de résultats, groupement par `SearchResultKind` et résolution de la destination.
- `Models/SearchResult.swift` — `SearchResultKind` (jeu / wiki / note / checklist / repère) et `SearchResult` (extrait, contexte, jaquette, identifiants wiki/page).
- `Components/SearchResultRow.swift` — Ligne d'un résultat : vignette de jaquette, extrait, contexte et icône de nature.

## Features/Home

Écran d'accueil (onglet Wikis) — **dashboard** : épinglés et activité récente. La liste complète vit dans « Mes jeux ».

- `HomeView.swift` — Vue principale : en-tête (ajout de jeu + recherche globale en sheet), épinglés, activité récente (5 entrées) et bilan de la collection, sur fond dégradé. Le résumé du bilan est visible de tous ; « Voir le bilan complet » pousse `StatsView` en premium, ouvre `PremiumUpgradeView` sinon. Deux états vides via `EmptyStateView` (onboarding + ajout de jeu si aucun jeu, explication de l'épinglage sinon).
- `HomeViewModel.swift` — `ObservableObject` : charge épinglés + total depuis SwiftData (`load(context:localization:)`) et construit le flux d'activité récente (wikis créés, notes modifiées, sessions consignées et changements de statut, fusionnés et triés, 5 max) ; `isDashboardEmpty` ; `target(for:context:)` résout la destination d'une entrée d'activité.
- `Models/HomeModel.swift` — Modèles de présentation : `WikiSummary` (mapping depuis `Wiki`, statut et temps de jeu inclus), `ActivityEntry` (jaquette + identifiants wiki/page cibles), `ActivityKind` (page/note/session/statut…), `ActivityTarget` (destination de navigation).
- `Components/HomeHeaderView.swift` — Bannière illustrée (`banner-home`) avec overlay dégradé, titre « Grym », tagline, bouton d'ajout et accès à la recherche globale superposés.
- `Components/HomeSearchBar.swift` — Barre de recherche locale (actuellement masquée, conservée pour plus tard).
- `Components/SectionHeaderView.swift` — En-tête de section réutilisable (icône + titre + compteur).
- `Components/HomeStatsSection.swift` — Résumé du bilan sur le dashboard : en-tête temps de jeu (`PlaytimeHeroView`), répartition par statut (barre + pastilles), trois chiffres clés (jeux, note moyenne, wikis) et accès au bilan complet (badge « Premium » si verrouillé).
- `Components/WikiCoverView.swift` — Cover d'un wiki : jaquette locale (offline) sinon CDN IGDB sinon dégradé teinté. Prend un `image_id`.
- `Components/ScoreBadgeView.swift` — Pastille de note 0–100 colorée selon le tier du thème.
- `Components/PinnedWikiCard.swift` — Carte d'un wiki épinglé.
- `Components/PinnedWikisSection.swift` — Section « Épinglés » (défilement horizontal).
- `Components/ActivityRowView.swift` — Ligne du flux d'activité récente.
- `Components/RecentActivitySection.swift` — Section « Activité récente » (carte + filets) ; chaque ligne est un bouton remontant l'entrée via `onSelect`.
- `Components/WikiRowView.swift` — Ligne de jeu réutilisable (cover, méta, statut, temps de jeu, stats blocs/photos/listes, note). Utilisée aussi par « Mes jeux ».
- `Components/AllWikisSection.swift` — Section liste de wikis avec compteur et état vide.

## Features/MyGames

Onglet « Mes jeux » : liste complète des jeux ajoutés.

- `MyGamesView.swift` — `NavigationStack` : bannière d'en-tête (`BannerHeaderView`, `banner-my-games`), barre tri + filtre, liste des wikis (`WikiRowView`), compteur (toujours sur la collection entière), état vide illustré (`EmptyStateView` + CTA d'ajout, mention du palier gratuit hors premium), suppression par menu contextuel, navigation vers `WikiDetailView` via une pile d'`ActivityTarget` (le wiki créé depuis la recherche est poussé automatiquement à la fermeture de la sheet, et la cible en attente de l'`AppRouter` — venue de Spotlight — est consommée à l'affichage).
- `MyGamesViewModel.swift` — `ObservableObject` : charge les wikis (`load` → `allWikis`), suppression via `WikiRepository` (`delete`), tri en mémoire selon `sortOption` et filtre par `statusFilter` (les deux persistés dans les UserDefaults) ; `wikis` expose la liste affichée, `hasNoGame` distingue collection vide et filtre sans résultat.
- `Components/GameSortMenu.swift` — Menu capsule de choix du critère de tri (`GameSortOption`).
- `Components/GameStatusFilterMenu.swift` — Menu capsule de filtrage par statut (`GameStatus`), « Tous » quand la sélection est `nil`.

## Features/PageDetail

Éditeur d'une page : titre éditable et flux de blocs (texte, checklist ; photo/carte à venir).

- `PageDetailView.swift` — `List` : titre, blocs et rétroliens ; ajout (menu de type), réorganisation (drag & drop via EditButton) et suppression de blocs ; sauvegarde à la sortie. Un lien `[[Titre]]` pousse la page ciblée, et la crée à la volée si elle n'existe pas. Un bloc photo/carte fraîchement ajouté ouvre directement le sélecteur d'images (`pendingPickerBlockID`). `autofocusTitle` place le focus dans le titre à l'ouverture d'une page fraîchement créée, texte présélectionné (`selectAllOnFocus`).
- `Components/TextBlockView.swift` — Bloc texte libre, lié à `Block.content`. Hors édition, les liens `[[Titre]]` sont rendus cliquables (couleur d'accent, gris si la page cible n'existe pas) et remontés via `onOpenLink` ; deux pastilles d'action : insertion d'un lien (en édition) et reprise de l'édition (hors édition). Le texte rendu ne porte aucun geste, pour ne pas avaler les taps sur les liens.
- `Components/PageLinkPickerView.swift` — Sheet listant les autres pages du wiki ; le titre choisi est inséré en `[[Titre]]`.
- `Components/PageBacklinksSection.swift` — Section « Cité par » : pages du wiki qui référencent la page courante.
- `Components/ChecklistBlockView.swift` — Bloc checklist : titre, items cochables, progression.
- `Components/PhotoBlockView.swift` — Bloc photo : galerie de miniatures locales, ajout via PhotosPicker (ouvert d'office sur un bloc tout juste créé, `autoPresentPicker`), suppression, ouverture plein écran au tap via QuickLook natif (`.quickLookPreview`, zoom/pan/partage/swipe).
- `MapEditorView.swift` — Éditeur plein écran d'une carte : image + pins (ajout au tap, drag, renommage/suppression) ; `autoPresentPicker` ouvre le sélecteur d'images à l'arrivée.
- `MapFullScreenView.swift` — Visionneuse plein écran d'une carte (lecture seule) : image bord à bord, safe areas ignorées, rotation paysage ; fermeture par la croix ou au tap.
- `Components/MapBlockView.swift` — Bloc carte : aperçu (image + pins) ou invite d'ajout ; ouvre l'éditeur au tap, ou d'office sur un bloc tout juste créé (`autoPresentPicker`). Deux pastilles d'action sur l'aperçu : plein écran (`MapFullScreenView`) et édition.
- `Components/AnnotatedMapView.swift` — Affichage image + pins (coordonnées relatives) ; mode lecture seule ou édition. Inclut `MapPinMarker`.
- `Components/AddBlockButton.swift` — Bouton + menu de choix du type de bloc (texte / checklist / photo / carte).
- `Components/EmptyBlocksPlaceholder.swift` — Placeholder d'un wiki sans bloc : en-tête illustré et une carte par type de bloc (icône, nom, rôle) pour guider la première création.

## Features/WikiDetail

Détail d'un wiki : édition directe du modèle via `@Bindable` (écart MVVM justifié) ; mutations structurelles via `WikiRepository`.

- `WikiDetailView.swift` — `List` : bandeau illustré, en-tête, note personnelle, journal de sessions, galerie des photos de l'utilisateur (aperçu QuickLook) et pages selon le mode d'affichage global choisi dans le Profil (Liste/Onglets/Cartes) ; épinglage, score, ajout (la page créée est ouverte immédiatement)/réorganisation (drag & drop en mode Liste)/suppression de pages ; `initialPage` ouvre directement une page à l'arrivée (navigation depuis l'activité récente).
- `WikiMediaViewModel.swift` — Charge les médias IGDB du jeu à l'ouverture du wiki (si jamais récupérés) et les persiste sur `Game` ; alimente le bandeau. Erreurs silencieuses (décoratif, réessai à la prochaine ouverture).
- `SessionEditorView.swift` — Sheet de création/modification d'une session (date, durée par heures + quarts d'heure, ressenti, note libre) ; saisie locale remontée en une fois via `onSave`.
- `Components/WikiDetailHeader.swift` — Cover, titre, méta, sélecteur de statut, bouton épingler et ligne de stats.
- `Components/WikiStatusMenu.swift` — Pastille de statut cliquable (icône + libellé + chevron) ouvrant un `Picker` inline des statuts disponibles.
- `Components/WikiSessionsCard.swift` — Carte « Sessions » : temps de jeu cumulé, nombre de sessions, journal tronqué à 3 entrées (dépliable), ajout / édition / suppression.
- `Components/WikiTemplateSection.swift` — Grille de modèles de démarrage, affichée tant que le jeu n'a aucun wiki ; un tap crée toutes les pages du modèle.
- `Components/SessionRowView.swift` — Ligne d'une session : pastille de ressenti, date, durée et note.
- `Components/WikiHeroBanner.swift` — Bandeau illustré pleine largeur en tête du wiki : file jusqu'au haut de l'écran (la barre de navigation se pose dessus), fondu vers le bas par un masque (se raccorde à n'importe quel thème).
- `Components/WikiMediaGallery.swift` — Galerie horizontale des photos ajoutées par l'utilisateur (blocs photo du wiki) ; vignettes locales (`ImageStore`), appui pour ouvrir l'aperçu. Masquée si aucune photo.
- `Components/PageCardView.swift` — Carte de page (mode Cartes).
- `Components/PageTabsView.swift` — Mode Onglets : chips de pages + aperçu léger (résumé des blocs) de la page sélectionnée.
- `Components/WikiScoreCard.swift` — Carte « Note personnelle » : score, palier et slider 0–100 à dégradé de tiers (drag par translation), replié par défaut derrière un en-tête cliquable.
- `Components/PageRowView.swift` — Ligne d'une page (icône, titre, nombre de blocs).

## Features/Stats

Bilan personnel de la collection. Le résumé vit sur l'accueil (`HomeStatsSection`) ; l'écran détaillé reste un avantage premium.

- `StatsView.swift` — Écran du bilan : en-tête temps de jeu, chiffres clés (jeux, wikis, note moyenne, sessions), répartitions par statut et par palier, classements de tête, volumes de contenu créé (3 par ligne) ; état vide si la collection est vide.
- `StatsViewModel.swift` — `ObservableObject` : agrège les wikis en mémoire (`load(context:localization:)`), exclut les jeux non notés de la moyenne et construit les répartitions et classements (5 entrées).
- `Models/StatsModel.swift` — `LibraryStats` (tous les compteurs et dérivés), `BreakdownSlice` (part d'une répartition) et `RankedGame` (entrée de classement).
- `Components/StatTileView.swift` — Tuile d'une statistique (icône, valeur, libellé).
- `Components/PlaytimeHeroView.swift` — En-tête du bilan : temps de jeu cumulé en dégradé d'accent, résumé des sessions (ou invitation à en consigner une) et pastille d'icône. Partagé accueil / écran complet.
- `Components/BreakdownBarView.swift` — Barre empilée proportionnelle d'une répartition.
- `Components/BreakdownChipsView.swift` — Légende compacte en pastilles défilables (accueil).
- `Components/StatsBreakdownView.swift` — Carte de répartition : `BreakdownBarView` + légende détaillée avec pourcentage et compte.
- `Components/RankingSection.swift` — Classement de tête : rang, jaquette, titre, valeur.

## Features/Premium

- `PremiumUpgradeView.swift` — Prompt d'upgrade (avantages + prix localisé StoreKit) : achat et restauration via `PremiumManager`, présenté à l'atteinte de la limite gratuite.

## Features/GameSearch

Ajout d'un jeu : recherche live IGDB, présentée en sheet depuis le bouton « + » de l'accueil.

- `GameSearchView.swift` — Vue : champ de recherche + états (invite, chargement, résultats, vide, erreur) ; à la sélection, persiste le wiki via `WikiRepository`, le remonte via `onSelect(Wiki)` puis referme.
- `GameSearchViewModel.swift` — `ObservableObject` : debounce, appel à `IGDBService`, machine à états `State`.
- `Components/GameSearchResultRow.swift` — Ligne de résultat (cover IGDB, titre, année de sortie).

## Features/Profile

- `ProfileView.swift` — Onglet Profil : fond dégradé Grym et cartes de réglages (Apparence : thème ; Langue ; Affichage : mode des wikis ; Développement : simulation du premium, DEBUG seulement).
- `Components/ProfileHeaderView.swift` — En-tête du profil : bannière illustrée (`BannerHeaderView`, `banner-profile`, hauteur compacte) avec titre et sous-titre superposés.
- `Components/StudioCreditComponent.swift` — Encart « Une création AppleMousse Studio » : logo, libellé et lien vers https://applemousse-studio.fr.
- `Components/ProfileSectionCard.swift` — Carte de section générique : `SectionHeaderView` + contenu sur surface translucide.
- `Components/ProfileSettingRow.swift` — Ligne de réglage : intitulé, contrôle et texte d'aide optionnel.
- `Components/ThemePickerComponent.swift` — Grille de vignettes de thèmes (calées en haut de ligne, retour tactile à l'appui) ; applique le thème via le `ThemeManager`, ou ouvre `PremiumUpgradeView` si le thème est verrouillé.
- `Components/ThemeSwatchView.swift` — Vignette d'un thème : mini-maquette de l'app (bandeau, ligne de jeu avec jaquette et pastille de note, palette d'accents) sur le fond et le halo du thème, nom et punchline ; sélection soulignée par un liseré et un halo d'accent, verrou premium en badge de coin sur voile léger.
- `Components/DebugPremiumToggle.swift` — Interrupteur de simulation du premium, compilé uniquement en DEBUG (`#if DEBUG`).
- `Components/LanguagePickerComponent.swift` — Sélecteur segmenté qui bascule la langue via le `LocalizationManager`.
- `Components/WikiModePickerComponent.swift` — Sélecteur segmenté du mode d'affichage des wikis via le `PreferencesManager`, suivi de l'aperçu du rendu.
- `Components/WikiModePreviewComponent.swift` — Aperçu miniature schématique du mode choisi (deux wikis factices), en Liste / Onglets / Cartes.
