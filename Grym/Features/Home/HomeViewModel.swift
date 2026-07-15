//
//  HomeViewModel.swift
//  Grym
//
//  Logique de l'écran d'accueil : expose les wikis, les épinglés et
//  l'activité récente. Données mockées en attendant la couche SwiftData.
//

import Combine
import SwiftUI

@MainActor
final class HomeViewModel: ObservableObject {

    /// Wikis épinglés (défilement horizontal).
    @Published private(set) var pinned: [WikiSummary] = []
    /// Nombre total d'épinglés (peut dépasser le nombre chargé/affiché).
    @Published private(set) var pinnedCount: Int = 0
    /// Flux d'activité récente.
    @Published private(set) var recentActivity: [ActivityEntry] = []
    /// Tous les wikis, triés par date de modification décroissante.
    @Published private(set) var allWikis: [WikiSummary] = []
    /// Texte de recherche locale.
    @Published var searchText: String = ""

    /// Wikis filtrés par la recherche locale (titre).
    var filteredWikis: [WikiSummary] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return allWikis }
        return allWikis.filter { $0.title.localizedCaseInsensitiveContains(query) }
    }

    init() {
        loadMockData()
    }

    // MARK: - Données mockées (temporaire)

    private func loadMockData() {
        let now = Date()
        let hour: TimeInterval = 3600
        let day: TimeInterval = 86_400

        let eldenRing = WikiSummary(
            title: "Elden Ring",
            coverTint: Color(hex: 0xE0A458),
            year: 2022, platform: "PS5",
            blockCount: 63, photoCount: 18, listCount: 9,
            score: 92, updatedAt: now.addingTimeInterval(-2 * hour)
        )
        let baldursGate = WikiSummary(
            title: "Baldur's Gate 3",
            coverTint: Color(hex: 0xC0392B),
            year: 2023, platform: "PC",
            blockCount: 42, photoCount: 11, listCount: 7,
            score: 88, updatedAt: now.addingTimeInterval(-1 * day)
        )
        let subnautica = WikiSummary(
            title: "Subnautica",
            coverTint: Color(hex: 0x2FA9D8),
            year: 2018, platform: "PC",
            blockCount: 47, photoCount: 24, listCount: 5,
            score: 76, updatedAt: now.addingTimeInterval(-3 * day)
        )
        let crimsonDesert = WikiSummary(
            title: "Crimson Desert",
            coverTint: Color(hex: 0xD35400),
            year: 2025, platform: "PS5",
            blockCount: 11, photoCount: 3, listCount: 2,
            score: 64, updatedAt: now.addingTimeInterval(-5 * day)
        )

        pinned = [eldenRing, baldursGate, subnautica]
        pinnedCount = 7
        allWikis = [eldenRing, baldursGate, subnautica, crimsonDesert]

        recentActivity = [
            ActivityEntry(
                kind: .checklist,
                title: "Added checklist",
                subtitle: "Elden Ring · Remembrance Bosses — 8 items",
                coverTint: eldenRing.coverTint,
                date: now.addingTimeInterval(-2 * hour)
            ),
            ActivityEntry(
                kind: .photos,
                title: "Added 3 photos",
                subtitle: "Baldur's Gate 3 · Tav Build — Sorcadin",
                coverTint: baldursGate.coverTint,
                date: now.addingTimeInterval(-1 * day)
            ),
            ActivityEntry(
                kind: .page,
                title: "New page",
                subtitle: "Elden Ring · Map: Lands Between",
                coverTint: eldenRing.coverTint,
                date: now.addingTimeInterval(-1 * day)
            ),
            ActivityEntry(
                kind: .note,
                title: "Updated note",
                subtitle: "Subnautica · Biome Log · Dunes",
                coverTint: subnautica.coverTint,
                date: now.addingTimeInterval(-3 * day)
            )
        ]
    }
}
