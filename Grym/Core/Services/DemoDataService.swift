//
//  DemoDataService.swift
//  Grym
//
//  Peuple (ou nettoie) la bibliothèque avec un jeu de données fictives,
//  destiné aux démos et aux captures d'écran App Store.
//
//  Les jeux de démo portent un `igdbId` **négatif** : un identifiant IGDB réel
//  étant toujours positif, la désactivation ne peut jamais toucher les données
//  de l'utilisateur. La suppression du `Game` emporte en cascade son wiki, ses
//  pages, ses blocs et ses sessions.
//
//  Compilé uniquement en DEBUG : absent des builds Release.
//

#if DEBUG
import Foundation
import SwiftData

@MainActor
enum DemoDataService {

    // MARK: - État

    /// Vrai si des données de démo sont présentes dans le magasin.
    static func isEnabled(in context: ModelContext) -> Bool {
        let descriptor = FetchDescriptor<Game>(predicate: #Predicate { $0.igdbId < 0 })
        return ((try? context.fetchCount(descriptor)) ?? 0) > 0
    }

    // MARK: - Activation

    /// Insère la bibliothèque de démo.
    ///
    /// Les jaquettes et les captures sont récupérées sur IGDB pour que les
    /// écrans soient illustrés comme en usage réel ; si le réseau échoue, on
    /// retombe sur les `image_id` de secours (ou sur l'absence d'illustration,
    /// que l'app sait déjà afficher).
    /// `igdb` : service injecté (test) ; `nil` utilise le service partagé.
    /// Valeur par défaut non littérale : `IGDBService.shared` est isolé au
    /// `MainActor`, inaccessible depuis l'expression par défaut d'un paramètre.
    static func enable(
        in context: ModelContext,
        language: AppLanguage,
        igdb: IGDBServiceProtocol? = nil
    ) async throws {
        guard !isEnabled(in: context) else { return }
        let igdb = igdb ?? IGDBService.shared

        for (index, blueprint) in blueprints.enumerated() {
            let remote = try? await igdb.searchGames(matching: blueprint.query, limit: 1).first
            let media = await media(for: remote?.id, igdb: igdb)

            let game = Game(
                igdbId: -(index + 1),
                title: remote?.name ?? blueprint.query,
                coverImageId: remote?.cover?.imageId ?? blueprint.fallbackCoverId,
                slug: remote?.slug,
                releaseYear: remote?.releaseYear ?? blueprint.year
            )
            // Toujours daté, même vide : le détail du wiki ne tentera pas de
            // recharger les médias avec l'identifiant négatif de démo.
            game.apply(media)
            context.insert(game)

            insertWiki(for: game, from: blueprint, language: language, in: context)
        }

        try context.save()
    }

    // MARK: - Désactivation

    /// Supprime toutes les données de démo (et rien d'autre).
    static func disable(in context: ModelContext) throws {
        let descriptor = FetchDescriptor<Game>(predicate: #Predicate { $0.igdbId < 0 })
        for game in try context.fetch(descriptor) {
            context.delete(game)
        }
        try context.save()
    }

    // MARK: - Insertion

    private static func media(for igdbId: Int?, igdb: IGDBServiceProtocol) async -> IGDBGameMedia {
        guard let igdbId else { return .empty }
        return (try? await igdb.gameMedia(id: igdbId)) ?? .empty
    }

    private static func insertWiki(
        for game: Game,
        from blueprint: DemoGameBlueprint,
        language: AppLanguage,
        in context: ModelContext
    ) {
        let updated = date(daysAgo: blueprint.updatedDaysAgo)

        let wiki = Wiki(game: game, score: blueprint.score, isPinned: blueprint.isPinned)
        wiki.createdAt = date(daysAgo: blueprint.updatedDaysAgo + 60)
        wiki.updatedAt = updated
        wiki.scoreUpdatedAt = blueprint.score > 0 ? updated : nil
        wiki.status = blueprint.status
        wiki.statusUpdatedAt = blueprint.status == .none ? nil : updated
        context.insert(wiki)

        for entry in blueprint.sessions {
            let session = PlaySession(
                date: date(daysAgo: entry.daysAgo),
                minutes: entry.minutes,
                mood: entry.mood,
                note: entry.note.value(language)
            )
            session.wiki = wiki
            context.insert(session)
        }

        for (pageOrder, pageBlueprint) in blueprint.pages.enumerated() {
            let page = Page(
                title: pageBlueprint.title.value(language),
                order: pageOrder,
                createdAt: date(daysAgo: blueprint.updatedDaysAgo + Double(pageOrder))
            )
            page.wiki = wiki
            context.insert(page)

            for (blockOrder, blockBlueprint) in pageBlueprint.blocks.enumerated() {
                let block = blockBlueprint.makeBlock(order: blockOrder, language: language)
                block.page = page
                context.insert(block)
            }
        }
    }

    private static func date(daysAgo: Double) -> Date {
        Date().addingTimeInterval(-daysAgo * 86_400)
    }
}

// MARK: - Modèle de données fictives

/// Texte de démo bilingue.
///
/// Les contenus fictifs ne passent pas par `Translation.swift` : ce sont des
/// données de fixture (des dizaines de lignes de notes de joueur), pas des
/// libellés d'interface. Ils restent malgré tout traduits FR/EN pour que les
/// captures soient exploitables dans les deux langues.
private struct DemoText {
    let fr: String
    let en: String

    init(_ fr: String, _ en: String) {
        self.fr = fr
        self.en = en
    }

    func value(_ language: AppLanguage) -> String {
        language == .french ? fr : en
    }
}

private enum DemoBlock {
    case text(DemoText)
    case checklist(DemoText, items: [(DemoText, Bool)])

    func makeBlock(order: Int, language: AppLanguage) -> Block {
        switch self {
        case .text(let text):
            return Block(type: .text, content: text.value(language), order: order)

        case .checklist(let title, let items):
            let block = Block(type: .checklist, content: "", order: order)
            block.checklist = ChecklistContent(
                title: title.value(language),
                items: items.map { ChecklistItem(text: $0.0.value(language), done: $0.1) }
            )
            return block
        }
    }
}

private struct DemoPage {
    let title: DemoText
    let blocks: [DemoBlock]
}

private struct DemoSession {
    let daysAgo: Double
    let minutes: Int
    let mood: SessionMood
    let note: DemoText
}

private struct DemoGameBlueprint {
    /// Titre recherché sur IGDB pour récupérer jaquette et captures réelles.
    /// Doit reprendre le libellé exact d'IGDB, ponctuation comprise : la
    /// recherche filtre sur `name ~ *"…"*`, un titre approximatif ne remonte rien.
    let query: String
    /// `image_id` de jaquette utilisé si IGDB est injoignable (tous vérifiés).
    let fallbackCoverId: String?
    let year: Int
    let score: Int
    let status: GameStatus
    let isPinned: Bool
    /// Ancienneté de la dernière activité, en jours (flux d'accueil).
    let updatedDaysAgo: Double
    let sessions: [DemoSession]
    let pages: [DemoPage]
}

// MARK: - Bibliothèque de démo

private extension DemoDataService {

    /// Bibliothèque fictive : statuts variés, notes étalées sur tous les paliers,
    /// sessions récentes — de quoi remplir accueil, bilan et classements.
    static var blueprints: [DemoGameBlueprint] {
        [
            DemoGameBlueprint(
                query: "Elden Ring",
                fallbackCoverId: "co4jni",
                year: 2022,
                score: 94,
                status: .playing,
                isPinned: true,
                updatedDaysAgo: 0.2,
                sessions: [
                    DemoSession(daysAgo: 0.3, minutes: 150, mood: .hyped,
                                note: DemoText("Malenia tombée à la 47e tentative.",
                                               "Malenia down on attempt 47.")),
                    DemoSession(daysAgo: 3, minutes: 95, mood: .rough,
                                note: DemoText("Farm de runes au Mohgwyn, long.",
                                               "Rune farming at Mohgwyn, a slog.")),
                    DemoSession(daysAgo: 8, minutes: 210, mood: .good,
                                note: DemoText("Leyndell explorée de fond en comble.",
                                               "Combed through all of Leyndell."))
                ],
                pages: [
                    DemoPage(
                        title: DemoText("Boss", "Bosses"),
                        blocks: [
                            .checklist(DemoText("Boss majeurs", "Main bosses"), items: [
                                (DemoText("Margit le Présage Déchu", "Margit, the Fell Omen"), true),
                                (DemoText("Godrick le Greffé", "Godrick the Grafted"), true),
                                (DemoText("Rennala, reine de la Pleine Lune", "Rennala, Queen of the Full Moon"), true),
                                (DemoText("Radahn, fléau des astres", "Starscourge Radahn"), true),
                                (DemoText("Malenia, lame de Miquella", "Malenia, Blade of Miquella"), true),
                                (DemoText("Radagon / Bête d'Elden", "Radagon / Elden Beast"), false)
                            ]),
                            .text(DemoText(
                                "Malenia : cendres Mimétique + saignement. Esquiver la Danse du Déluge en avançant, jamais en reculant.",
                                "Malenia: Mimic Tear + bleed build. Dodge Waterfowl Dance forward, never backward."
                            ))
                        ]
                    ),
                    DemoPage(
                        title: DemoText("Build", "Build"),
                        blocks: [
                            .text(DemoText(
                                "Sanguin niveau 150 — Force 20 / Dext 45 / Arcane 45.\nKatana Rivière de Sang + Nagakiba, talisman Griffe de Lord.",
                                "Bleed build, level 150 — Str 20 / Dex 45 / Arcane 45.\nRivers of Blood + Nagakiba, Lord's Exultation talisman."
                            )),
                            .checklist(DemoText("À récupérer", "Still to grab"), items: [
                                (DemoText("Larve de sang ×3", "Blood grease ×3"), true),
                                (DemoText("Talisman Griffe de Lord", "Lord's Exultation"), true),
                                (DemoText("Cendres de guerre : Sang de Seppuku", "Seppuku ash of war"), false)
                            ])
                        ]
                    )
                ]
            ),

            DemoGameBlueprint(
                // Titre exact d'IGDB (« III », pas « 3 ») : la recherche filtre
                // sur le nom, un libellé approximatif ne remonte rien.
                query: "Baldur's Gate III",
                fallbackCoverId: "co670h",
                year: 2023,
                score: 97,
                status: .completed,
                isPinned: true,
                updatedDaysAgo: 1.5,
                sessions: [
                    DemoSession(daysAgo: 1.5, minutes: 240, mood: .hyped,
                                note: DemoText("Acte 3 terminé, fin avec Karlach.",
                                               "Act 3 done, ending with Karlach.")),
                    DemoSession(daysAgo: 6, minutes: 180, mood: .good,
                                note: DemoText("Maison de l'Espoir, coffre vidé.",
                                               "House of Hope, vault cleared."))
                ],
                pages: [
                    DemoPage(
                        title: DemoText("Compagnons", "Companions"),
                        blocks: [
                            .checklist(DemoText("Recrutés", "Recruited"), items: [
                                (DemoText("Astarion", "Astarion"), true),
                                (DemoText("Karlach", "Karlach"), true),
                                (DemoText("Ombrecœur", "Shadowheart"), true),
                                (DemoText("Lae'zel", "Lae'zel"), true),
                                (DemoText("Minsc", "Minsc"), false)
                            ]),
                            .text(DemoText(
                                "Groupe final : barde tacticien, Karlach en tank, Ombrecœur soin, Astarion en éclaireur.",
                                "Final party: tactician bard, Karlach tanking, Shadowheart healing, Astarion scouting."
                            ))
                        ]
                    ),
                    DemoPage(
                        title: DemoText("Quêtes", "Quests"),
                        blocks: [
                            .checklist(DemoText("Acte 3", "Act 3"), items: [
                                (DemoText("Le tueur en série", "The serial killer"), true),
                                (DemoText("Le Cercle de Feu", "Circle of fire"), true),
                                (DemoText("Sauver Gortash… ou pas", "Deal with Gortash"), true)
                            ])
                        ]
                    )
                ]
            ),

            DemoGameBlueprint(
                query: "Hollow Knight",
                fallbackCoverId: "cobfzp",
                year: 2017,
                score: 91,
                status: .platinum,
                isPinned: true,
                updatedDaysAgo: 4,
                sessions: [
                    DemoSession(daysAgo: 4, minutes: 120, mood: .hyped,
                                note: DemoText("112 % — Panthéon du Hallownest bouclé.",
                                               "112% — Pantheon of Hallownest cleared.")),
                    DemoSession(daysAgo: 11, minutes: 75, mood: .rough,
                                note: DemoText("Chemin de la Douleur, encore.",
                                               "Path of Pain, again."))
                ],
                pages: [
                    DemoPage(
                        title: DemoText("Charmes", "Charms"),
                        blocks: [
                            .text(DemoText(
                                "Combo panthéon : Cœur d'acier + Marque du Rêveur + Lame rapide.",
                                "Pantheon loadout: Steady Body + Dreamshield + Quick Slash."
                            )),
                            .checklist(DemoText("Charmes manquants", "Missing charms"), items: [
                                (DemoText("Roi de Grimm", "Grimmchild"), true),
                                (DemoText("Cœur du Vide", "Void Heart"), true),
                                (DemoText("Fragile Force", "Fragile Strength"), true)
                            ])
                        ]
                    )
                ]
            ),

            DemoGameBlueprint(
                query: "The Witcher 3: Wild Hunt",
                fallbackCoverId: "coaarl",
                year: 2015,
                score: 89,
                status: .playing,
                isPinned: false,
                updatedDaysAgo: 2,
                sessions: [
                    DemoSession(daysAgo: 2, minutes: 130, mood: .good,
                                note: DemoText("Skellige, contrats de sorceleur en série.",
                                               "Skellige, witcher contracts back to back.")),
                    DemoSession(daysAgo: 9, minutes: 60, mood: .neutral,
                                note: DemoText("Gwynt contre tous les tenanciers de Novigrad.",
                                               "Gwent against every Novigrad innkeeper."))
                ],
                pages: [
                    DemoPage(
                        title: DemoText("Contrats", "Contracts"),
                        blocks: [
                            .text(DemoText(
                                "Niveau 34, quête principale à Kaer Morhen. Finir Skellige avant l'assaut.",
                                "Level 34, main quest at Kaer Morhen. Clear Skellige before the assault."
                            )),
                            .checklist(DemoText("Régions nettoyées", "Cleared regions"), items: [
                                (DemoText("Velen", "Velen"), true),
                                (DemoText("Novigrad", "Novigrad"), true),
                                (DemoText("Skellige", "Skellige"), false),
                                (DemoText("Toussaint", "Toussaint"), false)
                            ])
                        ]
                    )
                ]
            ),

            DemoGameBlueprint(
                query: "Hades",
                fallbackCoverId: "cob9kr",
                year: 2020,
                score: 88,
                status: .completed,
                isPinned: false,
                updatedDaysAgo: 5,
                sessions: [
                    DemoSession(daysAgo: 5, minutes: 85, mood: .hyped,
                                note: DemoText("Évasion n°12 réussie, arc d'Artémis.",
                                               "Escape #12 cleared with the bow.")),
                    DemoSession(daysAgo: 13, minutes: 45, mood: .good,
                                note: DemoText("Run rapide au bouclier.",
                                               "Quick shield run."))
                ],
                pages: [
                    DemoPage(
                        title: DemoText("Armes", "Weapons"),
                        blocks: [
                            .checklist(DemoText("Aspects débloqués", "Unlocked aspects"), items: [
                                (DemoText("Stygius — Nemesis", "Stygius — Nemesis"), true),
                                (DemoText("Coronacht — Chiron", "Coronacht — Chiron"), true),
                                (DemoText("Malphon — Talos", "Malphon — Talos"), false)
                            ])
                        ]
                    )
                ]
            ),

            DemoGameBlueprint(
                query: "Disco Elysium",
                fallbackCoverId: "co1sfj",
                year: 2019,
                score: 93,
                status: .completed,
                isPinned: false,
                updatedDaysAgo: 12,
                sessions: [
                    DemoSession(daysAgo: 12, minutes: 165, mood: .hyped,
                                note: DemoText("Enquête bouclée, fin sur la plage.",
                                               "Case closed, ending on the beach."))
                ],
                pages: [
                    DemoPage(
                        title: DemoText("Enquête", "Investigation"),
                        blocks: [
                            .text(DemoText(
                                "Build intellect / psyché. Ne jamais rater un jet d'Empathie.",
                                "Intellect / psyche build. Never skip an Empathy check."
                            ))
                        ]
                    )
                ]
            ),

            DemoGameBlueprint(
                query: "Cyberpunk 2077",
                fallbackCoverId: "coaih8",
                year: 2020,
                score: 82,
                status: .playing,
                isPinned: false,
                updatedDaysAgo: 7,
                sessions: [
                    DemoSession(daysAgo: 7, minutes: 110, mood: .good,
                                note: DemoText("Dogtown, contrats de Mr. Hands.",
                                               "Dogtown, Mr. Hands gigs.")),
                    DemoSession(daysAgo: 16, minutes: 70, mood: .neutral,
                                note: DemoText("Balade en ville, pas de quête.",
                                               "Drove around, no quests."))
                ],
                pages: [
                    DemoPage(
                        title: DemoText("Contrats", "Gigs"),
                        blocks: [
                            .checklist(DemoText("Dogtown", "Dogtown"), items: [
                                (DemoText("Le fantôme de Kurt", "Kurt's ghost"), true),
                                (DemoText("Livraison sous tension", "Hot delivery"), false)
                            ])
                        ]
                    )
                ]
            ),

            DemoGameBlueprint(
                query: "Stardew Valley",
                fallbackCoverId: "coa93h",
                year: 2016,
                score: 85,
                status: .playing,
                isPinned: false,
                updatedDaysAgo: 10,
                sessions: [
                    DemoSession(daysAgo: 10, minutes: 55, mood: .good,
                                note: DemoText("Année 2, serre débloquée.",
                                               "Year 2, greenhouse unlocked."))
                ],
                pages: [
                    DemoPage(
                        title: DemoText("Ferme", "Farm"),
                        blocks: [
                            .checklist(DemoText("Lots du centre communautaire", "Community center bundles"), items: [
                                (DemoText("Lot du printemps", "Spring crops"), true),
                                (DemoText("Lot du pêcheur", "Fisherman's bundle"), true),
                                (DemoText("Lot de la forge", "Blacksmith's bundle"), false)
                            ])
                        ]
                    )
                ]
            ),

            DemoGameBlueprint(
                query: "Celeste",
                fallbackCoverId: "cob9dh",
                year: 2018,
                score: 90,
                status: .platinum,
                isPinned: false,
                updatedDaysAgo: 21,
                sessions: [
                    DemoSession(daysAgo: 21, minutes: 95, mood: .rough,
                                note: DemoText("Chapitre 9 — 4 000 morts au compteur.",
                                               "Chapter 9 — 4,000 deaths in."))
                ],
                pages: [
                    DemoPage(
                        title: DemoText("Fraises", "Strawberries"),
                        blocks: [
                            .text(DemoText("175 / 175 fraises. Cœurs B-side complets.",
                                           "175 / 175 strawberries. All B-side hearts."))
                        ]
                    )
                ]
            ),

            DemoGameBlueprint(
                query: "Subnautica",
                fallbackCoverId: "co1o6r",
                year: 2018,
                score: 0,
                status: .backlog,
                isPinned: false,
                updatedDaysAgo: 26,
                sessions: [],
                pages: [
                    DemoPage(
                        title: DemoText("Notes", "Notes"),
                        blocks: [
                            .text(DemoText("À commencer après Elden Ring.",
                                           "To start after Elden Ring."))
                        ]
                    )
                ]
            ),

            DemoGameBlueprint(
                query: "Silent Hill 2",
                fallbackCoverId: "co2vyg",
                year: 2024,
                score: 0,
                status: .backlog,
                isPinned: false,
                updatedDaysAgo: 30,
                sessions: [],
                pages: []
            ),

            DemoGameBlueprint(
                query: "Starfield",
                fallbackCoverId: "co39vv",
                year: 2023,
                score: 61,
                status: .abandoned,
                isPinned: false,
                updatedDaysAgo: 34,
                sessions: [
                    DemoSession(daysAgo: 34, minutes: 40, mood: .rough,
                                note: DemoText("Trop de menus, j'arrête là.",
                                               "Too many menus, dropping it."))
                ],
                pages: []
            )
        ]
    }
}
#endif
