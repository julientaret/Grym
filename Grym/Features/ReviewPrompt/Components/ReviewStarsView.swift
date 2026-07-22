//
//  ReviewStarsView.swift
//  Grym
//
//  Cinq étoiles qui s'allument en cascade, façon score de fin de niveau.
//

import SwiftUI

struct ReviewStarsView: View {
    @Environment(\.theme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// Nombre d'étoiles déjà allumées (animé à l'apparition).
    @State private var litCount = 0

    private static let total = 5

    var body: some View {
        HStack(spacing: Theme.Spacing.small) {
            ForEach(0..<Self.total, id: \.self) { index in
                star(isLit: index < litCount)
            }
        }
        .task { await lightUp() }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(Self.total)/\(Self.total)")
    }

    private func star(isLit: Bool) -> some View {
        Image(systemName: "star.fill")
            .font(.system(size: Theme.Size.reviewStar, weight: .semibold))
            .foregroundStyle(
                isLit
                    ? AnyShapeStyle(LinearGradient(colors: [theme.accent, theme.accentAlt],
                                                   startPoint: .top, endPoint: .bottom))
                    : AnyShapeStyle(theme.secondaryText.opacity(0.25))
            )
            .shadow(color: isLit ? theme.accent.opacity(0.5) : .clear, radius: 10)
            .scaleEffect(isLit ? 1 : 0.7)
            .animation(.spring(response: 0.32, dampingFraction: 0.5), value: isLit)
    }

    /// Allumage une par une ; instantané si l'utilisateur réduit les animations.
    private func lightUp() async {
        guard !reduceMotion else {
            litCount = Self.total
            return
        }
        for index in 1...Self.total {
            try? await Task.sleep(for: .milliseconds(110))
            litCount = index
        }
    }
}

#Preview {
    ReviewStarsView()
        .padding()
        .background(Color.grymBgDark)
        .environment(\.theme, GrymBlueTheme())
}
