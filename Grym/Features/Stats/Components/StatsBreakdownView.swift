//
//  StatsBreakdownView.swift
//  Grym
//
//  Carte de répartition du bilan : barre empilée + légende détaillée
//  (une ligne par part, avec son compte).
//

import SwiftUI

struct StatsBreakdownView: View {
    let title: String
    let slices: [BreakdownSlice]

    @EnvironmentObject private var localization: LocalizationManager
    @Environment(\.theme) private var theme

    private var total: Int { slices.reduce(0) { $0 + $1.count } }

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.medium) {
            Text(title.uppercased())
                .font(.system(size: Theme.FontSize.caption, weight: .semibold))
                .foregroundStyle(theme.secondaryText)
                .tracking(1)

            BreakdownBarView(slices: slices)

            legend
        }
        .padding(Theme.Spacing.large)
        .background(
            RoundedRectangle(cornerRadius: Theme.Radius.large, style: .continuous)
                .fill(theme.surface.opacity(0.5))
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.Radius.large, style: .continuous)
                        .stroke(.white.opacity(0.06), lineWidth: 1)
                )
        )
    }

    private var legend: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.small) {
            ForEach(slices) { slice in
                HStack(spacing: Theme.Spacing.small) {
                    Circle().fill(slice.color).frame(width: 8, height: 8)
                    Text(localization.string(slice.nameKey))
                        .font(.system(size: Theme.FontSize.caption))
                        .foregroundStyle(theme.primaryText)

                    Spacer()

                    Text(percentage(of: slice))
                        .font(.system(size: Theme.FontSize.caption))
                        .foregroundStyle(theme.secondaryText)
                    Text("\(slice.count)")
                        .font(.system(size: Theme.FontSize.caption, weight: .bold))
                        .foregroundStyle(slice.color)
                        .frame(minWidth: Theme.Spacing.large, alignment: .trailing)
                }
            }
        }
    }

    private func percentage(of slice: BreakdownSlice) -> String {
        guard total > 0 else { return "" }
        return "\(Int((Double(slice.count) / Double(total) * 100).rounded())) %"
    }
}

#Preview {
    StatsBreakdownView(
        title: "Statuts",
        slices: [
            BreakdownSlice(id: "a", nameKey: .statusPlaying, color: .grymStatusPlaying, count: 3),
            BreakdownSlice(id: "b", nameKey: .statusCompleted, color: .grymStatusCompleted, count: 7),
            BreakdownSlice(id: "c", nameKey: .statusBacklog, color: .grymStatusBacklog, count: 12)
        ]
    )
    .padding()
    .background(Color.grymBgDark)
    .environmentObject(LocalizationManager())
    .environment(\.theme, GrymBlueTheme())
}
