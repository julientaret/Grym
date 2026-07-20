//
//  View+SelectAllOnFocus.swift
//  Grym
//
//  Sélectionne le contenu d'un champ de texte au moment où il prend le focus,
//  pour qu'une valeur par défaut soit prête à être écrasée.
//  SwiftUI n'expose pas la sélection d'un `TextField` : on passe par la
//  notification UIKit d'entrée en édition (écart justifié).
//

import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

private struct SelectAllOnFocus: ViewModifier {
    /// Remis à `false` dès la sélection effectuée : les champs suivants
    /// (blocs de texte) gardent le comportement standard.
    @Binding var isArmed: Bool

    func body(content: Content) -> some View {
        #if canImport(UIKit)
        content.onReceive(
            NotificationCenter.default.publisher(
                for: UITextField.textDidBeginEditingNotification
            )
        ) { notification in
            guard isArmed, let field = notification.object as? UITextField else { return }
            isArmed = false
            field.selectAll(nil)
        }
        #else
        content
        #endif
    }
}

extension View {
    /// Sélectionne tout le texte du prochain champ à prendre le focus,
    /// tant que `isArmed` est vrai.
    func selectAllOnFocus(isArmed: Binding<Bool>) -> some View {
        modifier(SelectAllOnFocus(isArmed: isArmed))
    }
}
