//
//  BreakdownChipsView.swift
//  Grym
//
//  Légende d'une répartition sous forme de pastilles compactes
//  (couleur · libellé · compte), défilables horizontalement.
//

import SwiftUI

struct BreakdownChipsView: View {
    let slices: [BreakdownSlice]

    @EnvironmentObject private var localization: LocalizationManager
    @Environment(\.theme) private var theme

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Theme.Spacing.small) {
                ForEach(slices) { slice in
                    HStack(spacing: Theme.Spacing.xSmall) {
                        Circle().fill(slice.color).frame(width: 6, height: 6)
                        Text(localization.string(slice.nameKey))
                            .foregroundStyle(theme.secondaryText)
                        Text("\(slice.count)")
                            .foregroundStyle(slice.color)
                            .fontWeight(.bold)
                    }
                    .font(.system(size: Theme.FontSize.caption, weight: .medium))
                    .padding(.horizontal, Theme.Spacing.small)
                    .padding(.vertical, Theme.Spacing.xSmall)
                    .background(Capsule().fill(slice.color.opacity(0.12)))
                }
            }
        }
    }
}

#Preview {
    BreakdownChipsView(slices: [
        BreakdownSlice(id: "a", nameKey: .statusPlaying, color: .grymStatusPlaying, count: 3),
        BreakdownSlice(id: "b", nameKey: .statusCompleted, color: .grymStatusCompleted, count: 7),
        BreakdownSlice(id: "c", nameKey: .statusBacklog, color: .grymStatusBacklog, count: 12)
    ])
    .padding()
    .background(Color.grymBgDark)
    .environmentObject(LocalizationManager())
    .environment(\.theme, GrymBlueTheme())
}
