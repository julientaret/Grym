//
//  GlobalSearchView.swift
//  Grym
//
//  Recherche globale dans toute la collection : jeux, pages, notes,
//  checklists et repères de carte. Présentée en sheet, avec sa propre
//  pile de navigation pour ouvrir directement le wiki ou la page trouvée.
//

import SwiftData
import SwiftUI

struct GlobalSearchView: View {
    @StateObject private var viewModel = GlobalSearchViewModel()
    @State private var target: ActivityTarget?

    @EnvironmentObject private var localization: LocalizationManager
    @Environment(\.theme) private var theme
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            content
                .background(background)
                .navigationTitle(localization.string(.searchTitle))
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button(localization.string(.commonCancel)) { dismiss() }
                    }
                }
                .navigationDestination(item: $target) { target in
                    WikiDetailView(wiki: target.wiki, initialPage: target.page)
                }
        }
        .searchable(
            text: $viewModel.query,
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: localization.string(.searchPlaceholder)
        )
        .onChange(of: viewModel.query) { _, _ in
            viewModel.search(context: modelContext)
        }
    }

    // MARK: Contenu

    @ViewBuilder
    private var content: some View {
        if !viewModel.hasQuery {
            hint(localization.string(.searchPrompt))
        } else if viewModel.results.isEmpty {
            hint(localization.string(.searchEmpty))
        } else {
            List {
                ForEach(viewModel.sections, id: \.kind) { section in
                    Section(localization.string(section.kind.sectionKey)) {
                        ForEach(section.results) { result in
                            Button {
                                target = viewModel.target(for: result, context: modelContext)
                            } label: {
                                SearchResultRow(result: result)
                            }
                            .buttonStyle(.plain)
                            .listRowBackground(theme.surface.opacity(0.4))
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
        }
    }

    private func hint(_ text: String) -> some View {
        VStack {
            Spacer()
            Text(text)
                .font(.system(size: Theme.FontSize.caption))
                .foregroundStyle(theme.secondaryText)
                .multilineTextAlignment(.center)
                .padding(Theme.Spacing.large)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: Fond

    private var background: some View {
        LinearGradient(
            colors: [theme.backgroundDeep, theme.background],
            startPoint: .top, endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}

#Preview {
    GlobalSearchView()
        .modelContainer(PreviewSampleData.container)
        .environmentObject(LocalizationManager())
        .environmentObject(PreferencesManager())
        .environment(\.theme, GrymBlueTheme())
}
