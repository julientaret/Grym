//
//  DebugDemoDataToggle.swift
//  Grym
//
//  Interrupteur de développement peuplant la bibliothèque de données fictives
//  (démos, captures d'écran App Store). Compilé uniquement en DEBUG.
//
//  Pas de ViewModel dédié : toute la logique (insertion, suppression, état)
//  vit dans `DemoDataService` ; la vue ne fait que déclencher et refléter.
//

#if DEBUG
import SwiftData
import SwiftUI

struct DebugDemoDataToggle: View {
    @EnvironmentObject private var localization: LocalizationManager
    @Environment(\.theme) private var theme
    @Environment(\.modelContext) private var context

    @State private var isOn = false
    @State private var isWorking = false

    var body: some View {
        Toggle(isOn: binding) {
            HStack(spacing: Theme.Spacing.small) {
                Text(localization.string(.profileDebugDemoData))
                    .font(.system(size: Theme.FontSize.body - 1, weight: .semibold))
                    .foregroundStyle(theme.primaryText)

                if isWorking {
                    ProgressView()
                        .controlSize(.small)
                        .tint(theme.accent)
                }
            }
        }
        .tint(theme.accent)
        .disabled(isWorking)
        .onAppear { isOn = DemoDataService.isEnabled(in: context) }
    }

    /// Binding piloté : l'état ne bascule qu'une fois l'opération terminée.
    private var binding: Binding<Bool> {
        Binding(
            get: { isOn },
            set: { newValue in
                isOn = newValue
                Task { await apply(newValue) }
            }
        )
    }

    private func apply(_ enabled: Bool) async {
        isWorking = true
        defer { isWorking = false }

        do {
            if enabled {
                try await DemoDataService.enable(in: context, language: localization.language)
            } else {
                try DemoDataService.disable(in: context)
            }
        } catch {
            // Réglage de debug : on se contente de refléter l'échec sur l'état.
            print("DemoDataService error: \(error)")
        }
        isOn = DemoDataService.isEnabled(in: context)
    }
}

#Preview {
    DebugDemoDataToggle()
        .padding()
        .background(Color.grymBlueBgDark)
        .modelContainer(PreviewSampleData.container)
        .environmentObject(LocalizationManager())
        .environment(\.theme, GrymBlueTheme())
}
#endif
