//
//  BreakdownBarView.swift
//  Grym
//
//  Barre empilée proportionnelle d'une répartition (statuts, paliers).
//  Partagée par le bilan complet et le résumé de l'accueil.
//

import SwiftUI

struct BreakdownBarView: View {
    let slices: [BreakdownSlice]
    var height: CGFloat = Theme.Size.breakdownBarHeight

    private var total: Int { slices.reduce(0) { $0 + $1.count } }

    var body: some View {
        GeometryReader { geo in
            HStack(spacing: 2) {
                ForEach(slices) { slice in
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [slice.color, slice.color.opacity(0.65)],
                                startPoint: .top, endPoint: .bottom
                            )
                        )
                        .frame(width: width(for: slice, in: geo.size.width))
                }
            }
        }
        .frame(height: height)
    }

    /// Largeur proportionnelle, en retirant les séparateurs de 2 pt.
    private func width(for slice: BreakdownSlice, in available: CGFloat) -> CGFloat {
        guard total > 0 else { return 0 }
        let spacing = CGFloat(max(slices.count - 1, 0)) * 2
        return max((available - spacing) * CGFloat(slice.count) / CGFloat(total), 2)
    }
}

#Preview {
    BreakdownBarView(slices: [
        BreakdownSlice(id: "a", nameKey: .statusPlaying, color: .grymStatusPlaying, count: 3),
        BreakdownSlice(id: "b", nameKey: .statusCompleted, color: .grymStatusCompleted, count: 7)
    ])
    .padding()
    .background(Color.grymBgDark)
}
