# Claude iOS Development Guidelines — AppleMousse Studio

## Architecture & Patterns

- Modèle privilégié : **MVVM**. Tout écart doit être justifié (ex : "MVVM trop lourd pour cette vue simple, utilisation de View directe").
- Découper au maximum les vues en sous-composants. Structure obligatoire :
  ```
  Features/
  └── NomFeature/
      ├── NomFeatureView.swift
      └── Components/
          ├── NomSubviewA.swift
          └── NomSubviewB.swift
  ```
- Toute logique métier reste dans le ViewModel, jamais dans la View.

## Conventions de nommage

- **Views** : `NomView.swift`
- **ViewModels** : `NomViewModel.swift`
- **Models** : `NomModel.swift`
- **Components** : `NomComponent.swift`
- **Extensions** : `Type+Fonctionnalité.swift` (ex : `Color+Theme.swift`)
- **Protocols** : préfixe ou suffixe explicite (ex : `NomService`, `NomRepositoryProtocol`)
- Anglais pour le code, français pour les commentaires si besoin.

## Design System

- Un fichier `Theme.swift` (ou `DesignSystem.swift`) centralise toutes les valeurs réutilisables :
  - Couleurs
  - Spacings (ex : `Spacing.small = 8`, `Spacing.medium = 16`)
  - Font sizes (ex : `FontSize.body = 16`)
  - Radius, durées d'animation, etc.
- Aucune valeur "magique" hardcodée dans les vues. Toujours référencer `Theme.*`.

## Localisation

- Support FR/EN par défaut sur tout nouveau texte affiché.
- Utiliser systématiquement `LocalizationManager` et `Translation.swift`.
- Aucune string en dur dans les vues.

## Données locales

- Toute persistance locale passe par **Swift Data**.
- Pas de UserDefaults pour des données structurées (uniquement pour préférences simples scalaires).

## Documentation — `architecture.md`

- Un fichier `architecture.md` est maintenu à la racine du projet, **créé dès l'initialisation** et **mis à jour à chaque modification**.
- Il contient :
  - Une description courte (1–2 lignes) de chaque fichier Swift du projet
  - Le rôle de chaque feature/module
  - Les dépendances notables entre composants
- Format attendu :
  ```markdown
  ## Features/NomFeature
  - `NomFeatureView.swift` — Vue principale de la feature X, affiche la liste des Y.
  - `NomFeatureViewModel.swift` — Gère le chargement et la logique de filtrage des Y.
  - `Components/NomSubview.swift` — Cellule réutilisable affichant un élément Y.

  ## Core
  - `Theme.swift` — Centralise couleurs, spacings et font sizes du design system.
  - `LocalizationManager.swift` — Gère la langue active et l'accès aux traductions.
  ```
- Après chaque session de modifications, mettre à jour les entrées concernées et ajouter les nouveaux fichiers.
- Ne pas documenter les fichiers générés automatiquement par Xcode (ex : `Assets.xcassets`, `Info.plist`).

## Gestion de version & Git

- **Un tag Git par version soumise à l'App Store** : format `vX.Y.Z` (ex : `v1.2.0`).
- Commits atomiques et messages clairs : `feat:`, `fix:`, `refactor:`, `test:`, `chore:`.
- Pas de commit direct sur `main` : passer par une branche de feature ou fix.

## Previews SwiftUI

- Chaque vue doit avoir une **preview fonctionnelle** avec données mockées représentatives.
- Si la preview nécessite un ViewModel, injecter un mock.

## Tests

- **Features critiques** (auth, achat, persistance, logique métier centrale) : tests unitaires obligatoires.
- **Features standard** : au moins un test de smoke sur le ViewModel si logique non triviale.
- Les tests se trouvent dans un dossier miroir `Tests/NomFeature/`.
- Nommage : `test_nomFonction_scenarioTeste_comportementAttendu`.

## Compilation

- Après chaque modification significative, tenter une compilation sur **iPhone 17** (simulateur).
- Signaler toute erreur ou warning introduit.

## Qualité & Communication

- **Concision** : questions et réponses courtes et directes.
- **Synthèse finale** : après toute modification, produire un résumé technique en 3–5 points max :
  - Ce qui a été modifié
  - Pourquoi (si non évident)
  - Impact potentiel
- Proposer des améliorations uniquement si elles apportent une valeur claire ; ne pas sur-ingénierer.
- En cas de choix architectural non standard, expliquer brièvement la raison.
- **Toujours s'exprimer en français** avec l'utilisateur, quelle que soit la langue des fichiers ou du code.
- **Ne pas surinterpréter les demandes spécifiques** : si la consigne est précise, s'y tenir strictement sans élargir le scope, sans ajouter de comportement non demandé.

## Gestion des erreurs

- Pas de `try!` ni de `force unwrap` (`!`) sauf cas justifié avec commentaire.
- Utiliser `Result<Success, Failure>` ou `async throws` selon le contexte.
- Les erreurs remontées à l'UI passent par le ViewModel (jamais directement depuis le Model).

## Performance & bonnes pratiques SwiftUI

- Préférer `@StateObject` pour l'ownership, `@ObservedObject` pour l'injection.
- Éviter les re-renders inutiles : extraire les sous-vues stables.
- Les images lourdes ou assets réseau : lazy loading systématique.
- Pas de logique dans `body` ; déléguer au ViewModel ou à des computed properties.
