//
//  PreferencesManager.swift
//  Grym
//
//  Détient les préférences d'affichage globales et les persiste.
//  Valeurs scalaires simples → UserDefaults (pas de Swift Data).
//

import Combine
import SwiftUI

@MainActor
final class PreferencesManager: ObservableObject {

    @Published private(set) var wikiPagesMode: WikiPagesMode

    private let wikiPagesModeKey = "wikiPagesMode"

    init() {
        wikiPagesMode = UserDefaults.standard.string(forKey: wikiPagesModeKey)
            .flatMap(WikiPagesMode.init(rawValue:)) ?? .list
    }

    /// Bascule le mode d'affichage des pages et persiste le choix.
    func selectWikiPagesMode(_ mode: WikiPagesMode) {
        guard mode != wikiPagesMode else { return }
        wikiPagesMode = mode
        UserDefaults.standard.set(mode.rawValue, forKey: wikiPagesModeKey)
    }
}
