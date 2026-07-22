//
//  StatsBreakdownView.swift
//  Grym
//
//  Répartition en barre empilée (statuts, paliers de note) avec légende.
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

            bar

            legend
        }
        .padding(Theme.Spacing.large)
        .background(
            RoundedRectangle(cornerRadius: Theme.Radius.large, style: .continuous)
                .fill(theme.surface.opacity(0.5))
        )
    }

    private var bar: some View {
        GeometryReader { geo in
            HStack(spacing: 2) {
                ForEach(slices) { slice in
                    Capsule()
                        .fill(slice.color)
                        .frame(width: width(for: slice, in: geo.size.width))
                }
            }
        }
        .frame(height: Theme.Size.breakdownBarHeight)
    }

    private var legend: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xSmall) {
            ForEach(slices) { slice in
                HStack(spacing: Theme.Spacing.small) {
                    Circle().fill(slice.color).frame(width: 8, height: 8)
                    Text(localization.string(slice.nameKey))
                        .font(.system(size: Theme.FontSize.caption))
                        .foregroundStyle(theme.primaryText)
                    Spacer()
                    Text("\(slice.count)")
                        .font(.system(size: Theme.FontSize.caption, weight: .semibold))
                        .foregroundStyle(theme.secondaryText)
                }
            }
        }
    }

    /// Largeur proportionnelle, en retirant les séparateurs de 2 pt.
    private func width(for slice: BreakdownSlice, in available: CGFloat) -> CGFloat {
        guard total > 0 else { return 0 }
        let spacing = CGFloat(max(slices.count - 1, 0)) * 2
        return max((available - spacing) * CGFloat(slice.count) / CGFloat(total), 2)
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
