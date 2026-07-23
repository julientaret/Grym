# Grym — Phase 2 : couche sociale

> Document de plan. Rédigé le 23/07/2026, à l'issue du brainstorm.
> Statut : **à valider**, rien n'est implémenté.

---

## 1. Objet

Ouvrir Grym sur un cercle **privé et choisi** : l'utilisateur se crée un compte, ajoute des
contacts par code, décide ce qu'il leur rend visible, et peut télécharger ou envoyer un wiki.

Le local reste maître. Aucune fonctionnalité existante ne doit devenir dépendante du réseau.

### Ce que ce document ne couvre pas

- Le partage **public** (onglet Explorer, wikis publics, upvotes), qui constituait la
  Phase 2 d'origine de `grym-spec.md`. Voir §11 — c'est un pivot assumé, pas un oubli.
- Une version web ou Android.

---

## 2. Décisions actées

| Sujet | Décision | Conséquence principale |
|---|---|---|
| Backend | **Supabase** (Postgres + RLS + Storage + Auth) | Remplace Appwrite dans `grym-spec.md` |
| Authentification | **Sign in with Apple** uniquement | Suppression de compte in-app obligatoire (App Store 5.1.1v) |
| Wiki reçu | **Copie figée** | Aucune synchro bidirectionnelle, aucun conflit d'édition |
| Note perso (0–100) | **Partageable, opt-in désactivé par défaut** | Contredit une promesse affichée — voir §11 |
| Médias (photos, cartes) | **Inclus** dans les wikis partagés | Storage, upload en tâche de fond, quotas, modération |

---

## 3. Principe d'architecture

Trois dépôts de données, et **un seul sens de circulation par lien**. C'est la règle qui
évite la classe de bugs la plus coûteuse d'un projet comme celui-ci.

```
   ┌──────────────┐   réplication bidirectionnelle   ┌──────────────┐
   │  SwiftData   │ ←───────────────────────────────→ │   CloudKit   │
   │   (local)    │        (mes appareils)            │  privé Apple │
   └──────┬───────┘                                   └──────────────┘
          │
          │  publication — sens unique, en tâche de fond
          ▼
   ┌──────────────┐
   │   Supabase   │  ← ce que mes contacts peuvent voir
   └──────┬───────┘
          │
          │  import — sens unique, ponctuel, déclenché par l'utilisateur
          ▼
   ┌──────────────┐
   │  SwiftData   │  → devient un objet local ordinaire, m'appartenant
   └──────────────┘
```

**Règles qui en découlent :**

1. Supabase n'écrit **jamais** dans un objet local que je possède. La publication est une
   projection sortante, jamais un aller-retour.
2. Un wiki importé n'est pas « un wiki distant affiché localement » : c'est un wiki à moi,
   créé avec de nouveaux identifiants. Il n'a plus aucun lien vivant avec sa source.
3. CloudKit réconcilie mes appareils entre eux. Supabase reçoit ensuite l'état gagnant,
   sans avoir à arbitrer quoi que ce soit.
4. **La visibilité est appliquée à la publication, pas à la lecture.** Si « partager mes
   notes » est désactivé, la note n'est pas envoyée — elle n'est pas envoyée puis masquée.
   Un champ non partagé n'existe pas côté serveur.

### Corollaire à ne pas rater

Désactiver une option de visibilité doit **dépublier immédiatement** ce qui l'a déjà été,
sans attendre la prochaine modification. Toute bascule d'un réglage met en file une
republication (ou une suppression) des lignes concernées.

---

## 4. Lot 1 — Synchro iCloud et fondations locales

Premier point de la phase, et prérequis dur à tout le reste : rien de social n'est
livrable avant lui. Il transforme la persistance actuelle en persistance synchronisable,
et livre au passage la synchro multi-appareils — une valeur utilisateur à elle seule.

### 4.1 Rendre les modèles compatibles CloudKit

`NSPersistentCloudKitContainer` impose des règles que le schéma actuel ne respecte pas :

- **Tout attribut non-optionnel doit avoir une valeur par défaut.** Aujourd'hui aucun ne
  l'a : `Wiki.score`, `Block.order`, `Block.content`, `Game.igdbId`, `Page.title`, les
  `createdAt`… Chaque `@Model` est à reprendre.
- **Toute relation doit être optionnelle** et avoir un inverse. C'est déjà le cas
  (`Wiki.game: Game?`, `Block.page: Page?`) — rien à faire.
- **Aucune contrainte `@Attribute(.unique)`.** Déjà respecté — il n'y en a aucune dans le
  projet.

### 4.2 Traiter la conséquence de l'absence d'unicité

`Game` est dédoublonné par `igdbId` **en code**, à l'insertion. Avec CloudKit, deux
appareils hors ligne peuvent créer chacun leur `Game` pour le même jeu, puis converger :
on se retrouve avec deux fiches du même jeu.

→ Prévoir une passe de fusion au démarrage : regrouper les `Game` de même `igdbId`,
rattacher les wikis au plus ancien, supprimer les doublons.

### 4.3 Migrer le stockage des images

`ImageStore` écrit des fichiers JPEG dans Application Support, avec
`isExcludedFromBackup = true`. Conséquence directe : **les photos ne suivraient pas la
synchro iCloud**, et un wiki partagé arriverait sans ses images. C'est incompatible avec
les deux décisions prises.

→ Migrer vers un `@Model ImageAsset` portant `@Attribute(.externalStorage) var data: Data`.
CloudKit transporte alors les blobs en `CKAsset` sans effort, et la donnée devient
transférable. Migration one-shot : lire les fichiers existants, insérer les rangs,
supprimer les fichiers.

⚠️ Pic d'occupation disque transitoire pendant la migration (fichiers + rangs coexistent).

### 4.4 Activer la synchro

Entitlement iCloud, conteneur CloudKit, `ModelConfiguration(cloudKitDatabase:)`.

⚠️ **Point de modèle économique à trancher.** `grym-spec.md` vend la synchro iCloud comme
un avantage **premium**. Or CloudKit synchronise le conteneur entier, pas un utilisateur :
le gating se fait en choisissant `.automatic` ou `.none` à l'ouverture du store, ce qui
impose une migration de store au moment de l'achat. Faisable, mais c'est un vrai coût pour
un bénéfice discutable. Voir §12.

**Livrable du lot :** mes wikis suivent sur mes appareils. Aucune UI nouvelle.

---

## 5. Lot 2 — Identité

### 5.1 Compte

- Projet Supabase, **région EU** (RGPD).
- Sign in with Apple natif iOS → `supabase.auth.signInWithIdToken(...)`.
- `SessionManager` (`@MainActor`, `ObservableObject`) : session, refresh, déconnexion.
  Jeton en Keychain, jamais en `UserDefaults`.

### 5.2 Le compte est optionnel

L'app fonctionne aujourd'hui sans compte et doit continuer. La connexion est une porte
d'entrée vers le social, pas un mur au lancement.

- Sans compte : tout marche, la section sociale affiche une invite.
- À la première connexion : **adoption** des données locales — tous les `Wiki.userId` à
  `nil` prennent l'identifiant du compte. (Le champ `userId` existe déjà sur `Wiki`, et
  n'est utilisé nulle part : l'amorce est en place.)
- À la déconnexion : les données locales restent, la publication s'arrête.

### 5.3 Pièges Sign in with Apple

- Le nom et l'e-mail ne sont fournis qu'à la **toute première** autorisation, jamais
  ensuite. À persister immédiatement, sinon ils sont définitivement perdus.
- « Masquer mon e-mail » renvoie une adresse relais : ne jamais traiter l'e-mail comme un
  identifiant stable ni l'afficher aux contacts.

### 5.4 Suppression de compte (obligatoire)

Guideline App Store 5.1.1(v) : suppression **dans l'app**, pas un lien vers un site.
Nécessite une Edge Function en `service_role` (l'utilisateur ne peut pas se supprimer
lui-même de `auth.users`). Doit purger : profil, contacts, publications, médias Storage.
Les données locales, elles, restent — c'est un compte qu'on supprime, pas un carnet.

### 5.5 Profil

`profiles` : `id`, `display_name`, `friend_code`, `created_at`.
Pas d'avatar en v1 (encore un canal de modération pour un gain faible).

---

## 6. Lot 3 — Contacts

### 6.1 Code ami

- 8 caractères, alphabet sans ambiguïté visuelle (ni `0/O`, ni `1/I/L`), affiché `A3F9-K2M7`.
- Généré **côté serveur** à la création du profil, unique.
- Recherche via une fonction `security definer` `find_profile_by_code(code)` qui ne renvoie
  que `(id, display_name)`.
  → Interdire la lecture directe de `profiles` : sans ça, la table entière est énumérable.
  → Rate-limiter l'appel (sinon le code se brute-force).

### 6.2 Flux d'ajout — avec consentement des deux côtés

```
A communique son code  →  B le saisit  →  demande en attente (B → A)
                                       →  A accepte  →  contact mutuel
```

Pas d'ajout unilatéral. La demande est refusable, et le refus est silencieux pour B.

### 6.3 Blocage

Blocage d'un utilisateur : rompt le lien, masque réciproquement, empêche toute nouvelle
demande. **Requis par l'App Store** dès qu'il y a du contenu entre utilisateurs (§10).

### 6.4 Modèle

`contacts (owner_id, contact_id, status, created_at)` — deux rangs à l'acceptation, un
par sens, pour que les policies RLS restent triviales à écrire et à lire.

---

## 7. Lot 4 — Visibilité et publication

### 7.1 Réglages

Écran dédié, **tout désactivé par défaut**. Granularité proposée :

| Réglage | Défaut | Contenu publié |
|---|---|---|
| Ma ludothèque | off | Titres, jaquettes, années |
| Mes statuts | off | En cours / terminé / abandonné… |
| Mon temps de jeu | off | Total par jeu |
| **Mes notes** | **off** | Note 0–100 |
| Mes wikis | off | Catalogue seul ; chaque wiki reste à publier explicitement |

Le dernier point compte : rendre « mes wikis » visible n'expose pas tout d'un coup.
C'est un interrupteur général, chaque wiki gardant le sien.

### 7.2 L'outbox

Un journal de publication local, **hors du conteneur CloudKit** (sinon la file se
réplique entre appareils et le même contenu part deux fois).

```
PublishTask { entity, entityId, revision, state, attempts, lastError }
```

- Alimenté à la sauvegarde, avec regroupement (~5 s) pour ne pas publier à chaque frappe.
- Rejoué : au premier plan, à la mise en arrière-plan, et via `BGProcessingTask`.
- Médias en `URLSession` **background** : l'upload survit à la suspension de l'app.
- Backoff exponentiel, échec durable rendu visible (discrètement) plutôt que silencieux.

### 7.3 Ordonnancement

Chaque entité publiée porte une `revision` monotone. Le serveur **rejette** une révision
antérieure à celle qu'il détient. Sans ça, deux appareils qui rattrapent leur retard dans
le désordre écrasent l'état récent par l'ancien.

### 7.4 Écran « Contacts »

Liste des contacts → fiche d'un contact → ce qu'il partage. Lecture seule, cache local,
consultable hors ligne une fois chargé.

---

## 8. Lot 5 — Wikis partagés

### 8.1 Un format d'échange, trois usages

Un wiki n'est pas transportable en l'état : `Block.content` est du JSON dans une chaîne,
et les médias sont des noms de fichiers locaux. Il faut le rendre autonome.

**`GrymWikiSnapshot` v1** — JSON versionné :

```json
{
  "format": 1,
  "wiki":  { "gameIgdbId": 1942, "title": "…", "publishedAt": "…" },
  "pages": [ { "title": "…", "order": 0,
               "blocks": [ { "type": "photo", "title": "Boss", "media": ["a1b2.jpg"] } ] } ],
  "media": [ { "name": "a1b2.jpg", "sha256": "…", "bytes": 148213 } ]
}
```

Le même format sert **trois transports** : télécharger depuis un contact, recevoir un
envoi ciblé, et — sans aucun backend — exporter un fichier `.grymwiki` par AirDrop.
Ce dernier point recoupe l'« Export Markdown » déjà promis en premium.

### 8.2 Publier

Snapshot → upload des médias manquants vers Storage (`{owner}/{wiki}/{sha256}.jpg`,
dédoublonné par empreinte) → écriture de la ligne `shared_wikis`.

**Le JSON du snapshot va dans Storage, pas dans une colonne `jsonb`.** Postgres est facturé
0,125 $/Go contre 0,0213 $/Go pour Storage : **six fois plus cher** pour une donnée qu'on ne
requête jamais — on la lit en bloc, on ne fait ni filtre ni jointure dessus. La table
`shared_wikis` ne garde que les métadonnées interrogeables (propriétaire, jeu, titre,
révision, taille, date) et un pointeur vers l'objet. Bénéfice secondaire : la base reste
petite, donc les sauvegardes et les restaurations restent rapides.

### 8.3 Vignettes

Chaque wiki publié embarque une **vignette générée à la publication, côté client**
(≤ 400 px, ~30 Ko), stockée à part du média original.

Sans elle, parcourir le catalogue d'un contact télécharge des images en 1600 px : à
2 000 comptes, c'est de l'ordre de 20 Go d'egress mensuel gaspillé, contre ~2 Go avec
vignettes. Le confort utilisateur suit le même chemin — une liste qui charge des images
pleine résolution est lente et coûte de la data mobile au lecteur.

> Générer la vignette au moment de la publication, et non à la demande, évite de dépendre
> d'un service de transformation d'images côté serveur.

### 8.4 Importer — copie figée

Télécharger le JSON, puis les médias, puis créer des objets locaux avec des **identifiants
neufs** et les noms de médias remappés. Le wiki obtenu est le mien : éditable, et
insensible aux modifications ultérieures de l'auteur.

Marquer l'origine (`importedFrom`, `importedAt`) — utile pour l'attribution à l'écran, et
pour proposer plus tard un « récupérer la dernière version » explicite.

### 8.5 Limites de partage par compte

Un quota ajouté après coup est bien plus douloureux à faire accepter qu'un quota présent
dès le premier jour. Il est donc livré avec le lot, pas ajouté quand la facture pique.

#### Les chiffres

Repère : un publieur type consomme **~13 Mo** (3 wikis × 12 photos × 350 Ko, cf. §13).
Les plafonds sont calés très au-dessus, pour rester invisibles à l'usage normal.

| Limite | Gratuit | Premium | Rôle |
|---|---|---|---|
| Wikis publiés simultanément | 3 | 30 | Différenciation premium |
| Volume de médias publiés | 150 Mo | 2 Go | Borne le compte pathologique |
| **Taille d'un wiki publié** | **50 Mo** | **50 Mo** | Protège le destinataire |

Le plafond par wiki est **identique dans les deux paliers**, et c'est volontaire : il n'est
pas là pour le budget mais pour celui qui télécharge. Recevoir un wiki de 500 Mo en 4G est
hostile, qu'il vienne d'un compte payant ou non.

#### Ce que les quotas protègent — et ce qu'ils ne protègent pas

Ils bornent **l'utilisateur aberrant** (celui qui déverse des milliers de captures), pas le
volume agrégé : 2 000 comptes premium au plafond feraient 4 To. Personne n'atteint son
plafond, et le coût agrégé est de toute façon couvert par la marge du Pro (§13).

Pas de quota d'egress par compte, en revanche. L'egress est causé par ceux qui
**téléchargent**, pas par l'auteur : le plafonner reviendrait à pénaliser quelqu'un pour
avoir écrit un wiki utile. Le levier correct est le cache, pas la sanction.

#### Application — côté serveur obligatoirement

Un quota vérifié dans l'app se contourne en dix minutes. La publication passe donc par une
Edge Function :

```
client → request_publish(wikiId, manifeste)
       → vérification du quota sur account_usage
       → renvoi d'URLs d'upload signées, ou refus motivé
client → upload direct vers Storage via ces URLs
       → confirm_publish()  → écriture de shared_wikis, mise à jour du compteur
```

L'écriture directe dans le bucket est refusée par RLS : aucun octet n'entre sans être passé
par le contrôle. Une table `account_usage (user_id, published_wikis, media_bytes)` tenue par
trigger sert de compteur.

#### À l'écran

- Une jauge dans les réglages de partage — « 42 Mo sur 150 Mo ».
- Un refus **actionnable** au moment de publier : ce qui dépasse, et quoi dépublier.
- **Aucune suppression automatique, jamais.** Un quota bloque une publication ; il ne touche
  ni au contenu déjà publié, ni — évidemment — à quoi que ce soit en local.

---

## 9. Lot 6 — Envoi ciblé

`wiki_transfers (from_user, to_user, snapshot_ref, created_at, accepted_at)`.

Boîte de réception : le destinataire **accepte** avant tout téléchargement. Pas de contenu
poussé sans consentement, ni de données rapatriées sans action.

Notifications push : optionnelles, à un lot ultérieur. Le badge sur l'onglet suffit en v1.

---

## 10. Conformité — bloquant pour la revue App Store

Dès qu'un utilisateur voit du contenu produit par un autre, la **Guideline 1.2 (UGC)**
s'applique. Elle exige, cumulativement :

- un **filtrage** du contenu répréhensible ;
- un **signalement** accessible depuis le contenu ;
- un **blocage** d'utilisateur ;
- des **coordonnées de contact** publiées ;
- une **action sous 24 h** sur un signalement, suppression du contenu et éjection de
  l'auteur.

> Ces éléments ne sont pas une finition de fin de projet. Sans eux, l'app est rejetée.
> Ils sont donc rattachés aux lots qui les rendent nécessaires : le blocage au lot 3, le
> signalement au lot 5.

À prévoir également :

- Mise à jour des **nutrition labels** et de `PrivacyInfo.xcprivacy` (identifiants, contenu
  utilisateur, usage).
- RGPD : export et suppression des données, région EU, mention du sous-traitant Supabase.
- Une **adresse de contact réelle** et surveillée.

---

## 11. Impacts sur l'existant

### 11.1 Contradictions levées dans `grym-spec.md`

`grym-spec.md` a été mis à jour en même temps que ce document :

| Ligne d'origine | Devenue |
|---|---|
| « Backend / Auth : Appwrite » | Supabase (Phase 2) |
| Phase 2 = wikis publics + Explorer + upvote | Phase 2 = synchro iCloud + social privé par contacts |
| Onglet « Explorer (Phase 2) » | Onglet « Contacts (Phase 2) » |
| « **Score toujours privé** : jamais visible des autres utilisateurs » | « Score privé par défaut : jamais publié sans activation explicite » |
| « Note personnelle : slider 0–100 (privé, jamais partagé) » | « privée par défaut ; partageable aux contacts sur activation explicite » |
| « Connexion / inscription via Appwrite » | « Sign in with Apple / Supabase, optionnelle » |
| « le fork crée une copie » | « le téléchargement crée une copie figée » |

**Reste ouvert :** « Synchro iCloud » figure toujours en avantage **premium** dans le
tableau freemium, alors qu'elle devient le point 1 de la phase. Voir §4.4 et §12.

### 11.2 La promesse de confidentialité affichée

Ce n'est pas qu'une ligne de spec. Le code l'affiche :

- `WikiScoreCard` porte le commentaire « Note strictement privée (jamais partagée) ».
- Une clé de traduction `wikiPrivate` = **« PRIVÉ » / « PRIVATE »** existe dans le
  catalogue.
- `Wiki.score` est documenté « Note personnelle privée (0–100), jamais partagée ».

Les utilisateurs actuels ont noté leurs jeux **sous cette garantie**. Rendre la note
partageable, même désactivée par défaut, demande donc :

1. de retirer ou reformuler le badge et les commentaires ;
2. de ne jamais activer le réglage par défaut, y compris à la mise à jour ;
3. d'expliciter le changement au moment où l'utilisateur active le social.

C'est le seul point du plan où une décision produit touche à un engagement déjà pris
envers les utilisateurs existants. Il mérite un texte soigné, pas une case à cocher de plus.

### 11.3 Amorces déjà présentes

- `Wiki.userId: String?` et `Wiki.isPublic: Bool` : déclarés, **utilisés nulle part**. Prêts.
- Onglet « Explorer (Phase 2) » prévu dans la navigation de la spec : la place existe, le
  contenu change.

---

## 12. Décisions ouvertes

| # | Question | Recommandation |
|---|---|---|
| 1 | Le social est-il premium ? | **Non.** La spec dit déjà « le partage reste gratuit pour favoriser l'acquisition organique », et brider l'effet réseau serait contre-productif. Le premium porte sur les **quotas** (§8.5) : le coût suit alors le revenu. Chiffrage à l'appui en §13 — 0,15 $ par utilisateur et par an. |
| 2 | La synchro iCloud reste-t-elle premium ? | **À rediscuter.** Le gating impose une migration de store à l'achat pour un bénéfice perçu faible. La rendre gratuite simplifie beaucoup le lot 1. |
| 3 | Le partage public (Explorer) est-il abandonné ou reporté ? | **Reporté.** Le modèle par contacts est un socle plus sain : mêmes snapshots, mêmes signalements, périmètre de modération réduit. Le public pourra s'y greffer. |
| 4 | Notifications push à l'envoi d'un wiki ? | Lot ultérieur. Badge d'onglet en v1. |
| 5 | Pseudo unique ou homonymes autorisés ? | Homonymes autorisés — le code ami est l'identifiant. Évite la course aux pseudos. |

---

## 13. Coûts d'exploitation

Relevé sur la grille Supabase de juillet 2026 — **à revérifier avant tout engagement**,
ces tarifs bougent.

### 13.1 Le palier gratuit ne tient pas

1 Go de stockage inclus, soit **~2 900 photos** au format produit par l'app
(1600 px, JPEG q0.8, cf. `ImageStore` → ~350 Ko par capture). Suffisant pour une bêta
fermée d'une centaine de personnes, saturé dès le vrai lancement.

Le **Pro à 25 $/mois** est donc le point de départ : 100 000 MAU, 8 Go de base,
100 Go de stockage, 250 Go d'egress.

### 13.2 Projection à 2 000 comptes

| | Prudent | Central | Lourd |
|---|---|---|---|
| Comptes qui publient | 20 % (400) | 40 % (800) | 60 % (1 200) |
| Wikis publiés × photos | 2 × 8 | 3 × 12 | 5 × 20 |
| Stockage | 2,2 Go | **10 Go** | 42 Go |
| Base de données | 35 Mo | 85 Mo | 300 Mo |
| Egress mensuel | 3 Go | 10 Go | 36 Go |
| **Facture mensuelle** | **25 $** | **25 $** | **25 $** |

Les trois scénarios tiennent dans les quotas inclus. Le plus lourd consomme 42 % du
stockage et 14 % de l'egress : **aucun dépassement**.

### 13.3 Le nombre d'utilisateurs n'est pas le facteur de coût

2 000 comptes, c'est **40× sous** l'allocation MAU gratuite (50 000). Ce qui pilote la
facture, c'est le **volume de photos publiées**.

- **Stockage** : les 100 Go inclus valent ~300 000 photos, soit **~20 000 utilisateurs** au
  rythme du scénario central. Et le dépassement est indolore : 0,0213 $/Go, donc +8,50 $/mois
  pour 400 Go supplémentaires.
- **Egress** : 250 Go/mois valent ~50 000 téléchargements de wiki. Très loin.

### 13.4 Le vrai risque : la popularité, pas la croissance

L'egress suit les **téléchargements**, pas les inscrits. Un wiki qui circule beaucoup coûte
plus cher que mille comptes inactifs, et les quotas par compte (§8.5) n'y changent rien —
ils bornent l'auteur, pas ses lecteurs.

Le levier est le cache : l'egress caché est facturé 0,03 $/Go contre 0,09 $/Go, soit **3×
moins cher**. D'où l'intérêt d'un stockage de médias immuables, adressés par empreinte
(§8.2) : ce type d'objet se met en cache indéfiniment.

### 13.5 Mise en perspective

25 $/mois pour 2 000 comptes = **~0,15 $ par utilisateur et par an**. Un seul achat premium
à 4,99 € finance environ 35 utilisateurs pendant un an.

Ce rapport conforte la recommandation §12-1 : rendre le social payant rapporterait peu et
coûterait l'effet réseau.

**Hors Supabase** : compte développeur Apple 99 $/an, IGDB gratuit via Twitch, CloudKit
gratuit dans les quotas Apple.

---

## 14. Risques

| Risque | Portée | Atténuation |
|---|---|---|
| Migration CloudKit sur des données existantes | Élevée — perte de données possible | Migration versionnée, testée sur une copie de store réel avant diffusion |
| Migration `ImageStore` → `ImageAsset` | Élevée — ce sont les photos des utilisateurs | Copier avant de supprimer, vérifier chaque rang inséré, ne purger qu'après succès |
| Doublons de `Game` après activation CloudKit | Moyenne — visible, pas destructeur | Passe de fusion au démarrage (§4.2) |
| Coût Storage/egress non borné | Faible — chiffré en §13 | Quotas par compte dès la v1 (§8.5), snapshots et vignettes hors Postgres (§8.2, §8.3) |
| Rejet App Store pour UGC | Élevée — bloque la sortie | Signalement, blocage et contact intégrés aux lots, pas en fin de parcours |
| Énumération des profils via le code ami | Moyenne — fuite de données | RPC `security definer` + rate limiting (§6.1) |

---

## 15. Séquencement

```
Lot 1  Synchro iCloud et fondations locales (CloudKit, ImageAsset, fusion Game)
Lot 2  Identité (Supabase, Sign in with Apple, suppression de compte)
Lot 3  Contacts (code ami, demandes, blocage)
Lot 4  Visibilité et publication (réglages, outbox, écran contacts)
Lot 5  Wikis partagés (snapshot v1, médias, import, signalement)
Lot 6  Envoi ciblé (transferts, boîte de réception)
```

Le lot 1 est livrable et utile **seul** : il apporte la synchro multi-appareils sans une
ligne de social. C'est le bon endroit pour s'arrêter si la suite doit attendre.

---

## 16. Prochaine étape

Valider §12 (décisions ouvertes) et §11.2 (promesse sur la note), puis attaquer le lot 1.
