//
//  PageLinkPickerView.swift
//  Grym
//
//  Sélecteur de page à lier depuis un bloc texte : liste les autres pages
//  du wiki et remonte le titre choisi (inséré en `[[Titre]]`).
//

import SwiftUI

struct PageLinkPickerView: View {
    let pages: [Page]
    var onSelect: (String) -> Void

    @EnvironmentObject private var localization: LocalizationManager
    @Environment(\.theme) private var theme
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Group {
                if pages.isEmpty {
                    Text(localization.string(.linkPickerEmpty))
                        .font(.system(size: Theme.FontSize.caption))
                        .foregroundStyle(theme.secondaryText)
                        .padding(Theme.Spacing.large)
                } else {
                    List(pages) { page in
                        Button {
                            onSelect(page.title)
                            dismiss()
                        } label: {
                            Label(page.title, systemImage: "book.pages")
                                .foregroundStyle(theme.primaryText)
                        }
                        .listRowBackground(theme.surface.opacity(0.5))
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(background)
            .navigationTitle(localization.string(.linkPickerTitle))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(localization.string(.commonCancel)) { dismiss() }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private var background: some View {
        LinearGradient(
            colors: [theme.backgroundDeep, theme.background],
            startPoint: .top, endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}

#Preview {
    PageLinkPickerView(pages: [], onSelect: { _ in })
        .environmentObject(LocalizationManager())
        .environment(\.theme, GrymBlueTheme())
}
