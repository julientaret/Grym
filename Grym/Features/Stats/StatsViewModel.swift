//
//  StatsViewModel.swift
//  Grym
//
//  Calcule le bilan personnel à partir du contexte SwiftData.
//  Corpus local et modeste : agrégation en mémoire à l'ouverture de l'écran.
//

import Combine
import SwiftData
import SwiftUI

@MainActor
final class StatsViewModel: ObservableObject {

    /// Taille des classements affichés.
    private static let rankingSize = 5

    @Published private(set) var stats = LibraryStats()

    func load(context: ModelContext, localization: LocalizationManager) {
        let wikis = (try? context.fetch(FetchDescriptor<Wiki>())) ?? []
        var stats = LibraryStats()

        stats.gameCount = wikis.count
        stats.pageCount = wikis.reduce(0) { $0 + $1.pages.count }
        stats.blockCount = wikis.reduce(0) { $0 + $1.blockCount }
        stats.photoCount = wikis.reduce(0) { $0 + $1.photoCount }
        stats.checklistCount = wikis.reduce(0) { $0 + $1.listCount }
        stats.sessionCount = wikis.reduce(0) { $0 + $1.sessions.count }
        stats.totalPlayMinutes = wikis.reduce(0) { $0 + $1.totalPlayMinutes }

        // Un score à 0 signifie « pas encore noté » : il fausserait la moyenne.
        let rated = wikis.filter { $0.score > 0 }
        stats.ratedCount = rated.count
        stats.averageScore = rated.isEmpty
            ? 0
            : Int((Double(rated.reduce(0) { $0 + $1.score }) / Double(rated.count)).rounded())

        stats.statusBreakdown = GameStatus.allCases.compactMap { status in
            let count = wikis.filter { $0.status == status }.count
            guard count > 0 else { return nil }
            return BreakdownSlice(
                id: status.rawValue, nameKey: status.nameKey,
                color: status.color, count: count
            )
        }

        stats.tierBreakdown = ScoreTier.allCases.compactMap { tier in
            let count = rated.filter { ScoreTier.tier(for: $0.score) == tier }.count
            guard count > 0 else { return nil }
            return BreakdownSlice(
                id: "\(tier.rawValue)", nameKey: tier.nameKey,
                color: tier.color, count: count
            )
        }

        stats.topRated = Self.ranking(
            from: rated.sorted { $0.score > $1.score }
        ) { "\($0.score)" }

        stats.mostPlayed = Self.ranking(
            from: wikis.filter { $0.totalPlayMinutes > 0 }
                .sorted { $0.totalPlayMinutes > $1.totalPlayMinutes }
        ) { wiki in
            wiki.totalPlayMinutes.playtimeLabel(
                hourUnit: localization.string(.durationHourUnit),
                minuteUnit: localization.string(.durationMinuteUnit)
            )
        }

        self.stats = stats
    }

    /// Construit un classement de tête à partir de wikis déjà triés.
    private static func ranking(
        from wikis: [Wiki],
        value: (Wiki) -> String
    ) -> [RankedGame] {
        wikis.prefix(rankingSize).compactMap { wiki in
            guard let game = wiki.game else { return nil }
            return RankedGame(
                id: "\(game.igdbId)",
                title: game.title,
                coverImageId: game.coverImageId,
                coverTint: .grymTint(for: game.title),
                value: value(wiki)
            )
        }
    }
}
