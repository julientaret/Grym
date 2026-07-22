//
//  SessionEditorView.swift
//  Grym
//
//  Éditeur d'une session de jeu (création ou modification), présenté en sheet.
//  Saisie locale via `@State` puis remontée en une fois par `onSave` : pas de
//  ViewModel, la vue ne porte aucune logique métier (écart MVVM assumé).
//

import SwiftUI

struct SessionEditorView: View {
    /// Session existante à modifier ; `nil` pour une création.
    var session: PlaySession?
    var onSave: (Date, Int, SessionMood, String) -> Void

    @EnvironmentObject private var localization: LocalizationManager
    @Environment(\.theme) private var theme
    @Environment(\.dismiss) private var dismiss

    @State private var date: Date
    @State private var hours: Int
    @State private var minutes: Int
    @State private var mood: SessionMood
    @State private var note: String

    init(session: PlaySession? = nil, onSave: @escaping (Date, Int, SessionMood, String) -> Void) {
        self.session = session
        self.onSave = onSave
        let total = session?.minutes ?? 60
        _date = State(initialValue: session?.date ?? Date())
        _hours = State(initialValue: total / 60)
        _minutes = State(initialValue: (total % 60) / 15 * 15)
        _mood = State(initialValue: session?.mood ?? .good)
        _note = State(initialValue: session?.note ?? "")
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    DatePicker(
                        localization.string(.sessionDate),
                        selection: $date,
                        displayedComponents: .date
                    )
                    durationRow
                }
                .listRowBackground(theme.surface.opacity(0.5))

                Section(localization.string(.sessionMood)) {
                    moodPicker
                }
                .listRowBackground(theme.surface.opacity(0.5))

                Section(localization.string(.sessionNote)) {
                    TextField(
                        localization.string(.sessionNotePlaceholder),
                        text: $note,
                        axis: .vertical
                    )
                    .lineLimit(3...6)
                }
                .listRowBackground(theme.surface.opacity(0.5))
            }
            .scrollContentBackground(.hidden)
            .background(background)
            .navigationTitle(localization.string(
                session == nil ? .sessionEditorTitle : .sessionEditorEditTitle
            ))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(localization.string(.commonCancel)) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(localization.string(.commonSave)) {
                        onSave(date, totalMinutes, mood, note)
                        dismiss()
                    }
                    .disabled(totalMinutes == 0)
                }
            }
        }
    }

    private var totalMinutes: Int { hours * 60 + minutes }

    // MARK: Durée

    private var durationRow: some View {
        HStack {
            Text(localization.string(.sessionDuration))
            Spacer()
            Picker("", selection: $hours) {
                ForEach(PlaySession.hourChoices, id: \.self) { value in
                    Text("\(value) \(localization.string(.durationHourUnit))").tag(value)
                }
            }
            .labelsHidden()
            Picker("", selection: $minutes) {
                ForEach(PlaySession.minuteChoices, id: \.self) { value in
                    Text("\(value) \(localization.string(.durationMinuteUnit))").tag(value)
                }
            }
            .labelsHidden()
        }
    }

    // MARK: Ressenti

    private var moodPicker: some View {
        HStack(spacing: Theme.Spacing.small) {
            ForEach(SessionMood.allCases) { option in
                Button {
                    mood = option
                } label: {
                    VStack(spacing: Theme.Spacing.xSmall) {
                        Image(systemName: option.systemImage)
                            .font(.system(size: Theme.FontSize.body, weight: .semibold))
                        Text(localization.string(option.nameKey))
                            .font(.system(size: Theme.FontSize.caption, weight: .medium))
                    }
                    .foregroundStyle(option == mood ? option.color : theme.secondaryText)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Theme.Spacing.small)
                    .background(
                        RoundedRectangle(cornerRadius: Theme.Radius.medium, style: .continuous)
                            .fill(option == mood ? option.color.opacity(0.15) : .clear)
                    )
                }
                .buttonStyle(.plain)
            }
        }
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
    SessionEditorView(onSave: { _, _, _, _ in })
        .environmentObject(LocalizationManager())
        .environment(\.theme, GrymBlueTheme())
}
