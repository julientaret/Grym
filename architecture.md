# Architecture — Grym

Carnet de jeu personnel pour gamers (iOS / macOS, SwiftUI, offline-first).
Chaque jeu possède un wiki personnel composé de pages et de blocs (texte, photos,
checklists, cartes annotées). Note personnelle privée de 0 à 100 par jeu.

## App

- `GrymApp.swift` — Point d'entrée `@main`, injecte le `LocalizationManager` et affiche `RootTabView`.

## Core

- `Core/Theme/Theme.swift` — Rôles sémantiques du design system (couleurs adaptatives, spacings, font sizes, radius, durées) ; les vues référencent uniquement `Theme.*`.
- `Core/Theme/Color+Theme.swift` — Palette brute (tokens `grym*`), helper de tier de note 0–100, init `hex` et init adaptatif clair/sombre.
- `Core/Localization/LocalizationManager.swift` — `ObservableObject` gérant la langue active et l'accès aux traductions ; injecté dans l'environnement.
- `Core/Localization/Translation.swift` — Catalogue des traductions FR/EN, enum `AppLanguage` et clés `TranslationKey`.

## Features/Root

- `RootTabView.swift` — Navigation principale : `TabView` à trois onglets (Notes, Rechercher, Profil).

## Features/Notes

- `NotesView.swift` — Onglet Notes, carnet de jeu personnel (placeholder à ce stade).

## Features/Search

- `SearchView.swift` — Onglet Rechercher, recherche de jeux via IGDB (placeholder à ce stade).

## Features/Profile

- `ProfileView.swift` — Onglet Profil, préférences et données utilisateur (placeholder à ce stade).
