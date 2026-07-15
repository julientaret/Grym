//
//  View+GrymListRow.swift
//  Grym
//
//  Style de ligne de `List` transparent : séparateur masqué, fond clair,
//  insets Grym. Permet de garder l'apparence « carte » des vues tout en
//  bénéficiant du drag & drop natif (`.onMove`) des `List`.
//

import SwiftUI

extension View {
    func grymBlockRow() -> some View {
        self
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets(
                top: Theme.Spacing.small,
                leading: Theme.Spacing.large,
                bottom: Theme.Spacing.small,
                trailing: Theme.Spacing.large
            ))
    }
}
