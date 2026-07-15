# Grym — App Spec

## Concept

**Grym** est une app iOS-first (adaptation macOS) permettant de créer des wikis personnels par jeu vidéo. L'utilisateur peut prendre des notes, photos, checklists et cartes annotées pendant ses sessions de jeu. Les jeux sont récupérés via l'API IGDB.

---

## Stack technique

| Brique | Choix |
|---|---|
| UI | SwiftUI |
| Persistance locale | SwiftData (offline-first) |
| Backend / Auth | Appwrite |
| Metadata jeux | IGDB API |
| Caméra / Photos | PhotosUI + AVFoundation |
| Navigation | NavigationStack + TabView |
| Paiement | StoreKit 2 |
| macOS | Adaptation native (sidebar au lieu de tab bar) |

---

## Design

- **Mode** : Dark et Light
- **Style** : Moderne, card-based (type Notion)
- **Couleur principale** : Violet `#534AB7`
- **Typographie** : SF Pro (système iOS)

---

## Structure de navigation

```
TabView
├── Wikis (home)
├── Explorer (Phase 2)
└── Profil
```

---

## Écrans MVP

### 1. Home — Mes wikis
- Liste des wikis créés, triés par date de modification
- Barre de recherche locale
- Card par jeu : cover IGDB + titre + meta (nb blocs, photos, listes)
- Bouton "Ajouter un jeu" → déclenche recherche IGDB
- Indicateur visuel si la limite de 10 jeux est atteinte

### 2. Recherche IGDB
- Champ de recherche live
- Résultats : cover + titre + année + plateforme
- Tap → crée le wiki et ouvre l'éditeur
- Bloqué si limite free atteinte → prompt upgrade premium

### 3. Wiki d'un jeu
- Header : cover IGDB + titre du jeu
- Note personnelle : slider 0–100 (privé, jamais partagé)
- Pages : liste de sections nommées par l'utilisateur
- Tap sur une page → ouvre le flux de blocs

### 4. Éditeur de page (flux de blocs)
- Types de blocs :
  - Texte libre (Markdown)
  - Photo (caméra ou galerie)
  - Checklist (quêtes, objets, objectifs...)
  - Carte annotée (image uploadée + pins)
- Ajout de bloc via bouton `+` en bas
- Réorganisation par drag & drop

### 5. Profil / Auth
- Connexion / inscription via Appwrite
- Statut free / premium
- Bouton d'achat premium (StoreKit 2)
- Restauration d'achat

---

## Modèle de données (SwiftData)

```swift
Game
├── igdbId: Int
├── title: String
├── coverURL: String
├── slug: String
└── platform: String

Wiki
├── game: Game
├── userId: String
├── score: Int        // 0–100, strictement privé
├── isPublic: Bool
├── createdAt: Date
├── updatedAt: Date
└── pages: [Page]

Page
├── wiki: Wiki
├── title: String
├── order: Int
└── blocks: [Block]

Block
├── page: Page
├── type: BlockType   // text | photo | checklist | map
├── content: String   // JSON selon type
└── order: Int
```

---

## Modèle freemium

| Free | Premium (8,99€ — paiement unique) |
|---|---|
| 10 jeux max | Jeux illimités |
| Wikis illimités par jeu | Synchro iCloud |
| Tous les types de blocs | Thèmes visuels |
| Partage (Phase 2) | Export PDF / Markdown |
| Suppression de jeux possible | Widgets iOS |
| | Icônes d'app alternatives |
| | Stats personnelles |

### Logique de limite free
- Maximum 10 jeux ajoutés simultanément
- L'utilisateur peut supprimer des jeux pour en ajouter de nouveaux sans payer
- Les wikis existants ne sont jamais supprimés ni verrouillés
- Prompt d'upgrade affiché à l'ajout du 11ème jeu

### Stratégie de lancement
Prix de lancement à **4,99€** pour les premières semaines, puis passage à **8,99€**. Récompense les early adopters et crée une urgence d'achat.

---

## Phase 2 — Partage communautaire

> Déployé uniquement quand la base d'utilisateurs le justifie.

- Un wiki peut être rendu public
- Les wikis publics sont consultables via l'onglet "Explorer"
- Système de pertinence (upvote) pour remonter les meilleurs wikis par jeu
- Téléchargement/fork d'un wiki public : crée une copie locale éditable, l'original n'est pas modifié
- Le score (0–100) est toujours privé, même sur les wikis partagés
- Le partage reste **gratuit** pour favoriser l'acquisition organique

---

## Contraintes importantes

- **Score toujours privé** : jamais visible des autres utilisateurs
- **Offline-first** : tout le contenu est accessible sans connexion via SwiftData
- **Wiki partagé immuable** : le fork crée une copie, l'original reste intact
- **Achat via StoreKit 2** : paiement unique, restauration d'achat obligatoire
