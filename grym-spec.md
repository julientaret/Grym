# Grym — App Spec

## Concept

**Grym** est une app iOS-first (adaptation macOS) permettant de créer des wikis personnels par jeu vidéo. L'utilisateur peut prendre des notes, photos, checklists et cartes annotées pendant ses sessions de jeu. Les jeux sont récupérés via l'API IGDB.

---

## Stack technique

| Brique | Choix |
|---|---|
| UI | SwiftUI |
| Persistance locale | SwiftData (offline-first) |
| Backend / Auth | Supabase (Phase 2) |
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
├── Contacts (Phase 2)
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
- Note personnelle : slider 0–100 (privée par défaut ; partageable aux contacts en Phase 2, sur activation explicite)
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
- Connexion via Sign in with Apple / Supabase (Phase 2, optionnelle)
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
├── score: Int        // 0–100, privé par défaut
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

## Phase 2 — Synchro iCloud et couche sociale

> Plan détaillé : **`phase2-social.md`**.
> Le partage se fait dans un **cercle privé et choisi**, pas en public.

### 1. Synchro iCloud (prérequis à tout le reste)

- SwiftData adossé à CloudKit : les wikis suivent sur tous les appareils de l'utilisateur
- Impose de reprendre chaque `@Model` (valeurs par défaut) et de migrer le stockage des photos
- Livrable et utile seul, sans une ligne de social

### 2. Compte

- Sign in with Apple, via **Supabase**
- Le compte reste **optionnel** : l'app fonctionne intégralement sans
- Suppression du compte dans l'app (obligation App Store)

### 3. Contacts

- Ajout par **code ami** unique, avec acceptation des deux côtés
- Blocage d'un utilisateur

### 4. Visibilité

- L'utilisateur choisit ce que ses contacts voient : ludothèque, statuts, temps de jeu,
  notes, wikis — **tout désactivé par défaut**
- La visibilité s'applique à la publication : un champ non partagé n'est pas envoyé
- Publication en tâche de fond, à la modification

### 5. Wikis partagés

- Un wiki publié est transporté en **snapshot autonome**, médias compris
- Le télécharger crée une **copie figée** : elle m'appartient, elle n'est plus liée à l'original
- Le même format servira l'export de fichier (AirDrop, Markdown)

### 6. Envoi ciblé

- Envoi d'un wiki à un contact ; le destinataire accepte avant tout téléchargement

### Principes

- **Le local reste maître** : aucune fonctionnalité existante ne devient dépendante du réseau
- **Aucune synchro bidirectionnelle** avec le serveur : publication sortante, import ponctuel
- Signalement, blocage et contact éditeur sont livrés **avec** le social, pas après
  (Guideline App Store 1.2 sur le contenu utilisateur)
- Le partage reste **gratuit** pour favoriser l'acquisition organique ; le premium porte
  sur les quotas

---

## Contraintes importantes

- **Score privé par défaut** : jamais publié tant que l'utilisateur ne l'active pas explicitement (Phase 2)
- **Offline-first** : tout le contenu est accessible sans connexion via SwiftData
- **Wiki partagé immuable** : le téléchargement crée une copie figée, l'original reste intact
- **Achat via StoreKit 2** : paiement unique, restauration d'achat obligatoire
