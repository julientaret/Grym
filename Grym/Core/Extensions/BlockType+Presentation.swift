//
//  BlockType+Presentation.swift
//  Grym
//
//  Habillage d'un type de bloc : nom, description et couleur d'accent.
//  Centralisé ici pour que l'éditeur, la palette d'ajout et l'état vide
//  parlent tous le même langage visuel.
//

import SwiftUI

extension BlockType {

    /// Clé de traduction du nom affiché.
    var nameKey: TranslationKey {
        switch self {
        case .text:      .blockTypeText
        case .photo:     .blockTypePhoto
        case .checklist: .blockTypeChecklist
        case .map:       .blockTypeMap
        }
    }

    /// Clé de traduction de la phrase qui explique le rôle du bloc.
    var hintKey: TranslationKey {
        switch self {
        case .text:      .blockTypeTextHint
        case .photo:     .blockTypePhotoHint
        case .checklist: .blockTypeChecklistHint
        case .map:       .blockTypeMapHint
        }
    }

    /// Accent du type, pris dans la palette du thème actif pour que chaque
    /// type garde la même couleur d'un écran à l'autre.
    func accent(in theme: any AppTheme) -> Color {
        let accents = theme.pageAccents
        guard let index = Self.allCases.firstIndex(of: self) else { return theme.accent }
        return accents[index % accents.count]
    }
}
