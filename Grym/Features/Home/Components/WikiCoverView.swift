//
//  WikiCoverView.swift
//  Grym
//
//  Cover d'un wiki : image IGDB en lazy loading si disponible,
//  sinon un dégradé teinté avec halo (repli visuel).
//

import SwiftUI

struct WikiCoverView: View {
    let coverURL: URL?
    let tint: Color
    var cornerRadius: CGFloat = Theme.Radius.medium
    /// Titre optionnel imprimé sur le repli (rappelle les jaquettes maquette).
    var caption: String? = nil

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(.clear)
            .overlay {
                if let coverURL {
                    AsyncImage(url: coverURL) { phase in
                        switch phase {
                        case .success(let image):
                            image.resizable().scaledToFill()
                        default:
                            placeholder
                        }
                    }
                } else {
                    placeholder
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }

    // MARK: Repli dégradé

    private var placeholder: some View {
        ZStack {
            LinearGradient(
                colors: [tint.opacity(0.45), Color.black.opacity(0.65)],
                startPoint: .top,
                endPoint: .bottom
            )
            RadialGradient(
                colors: [tint.opacity(0.9), .clear],
                center: UnitPoint(x: 0.5, y: 0.32),
                startRadius: 2,
                endRadius: 120
            )
            .blendMode(.screen)

            if let caption {
                VStack {
                    Spacer()
                    Text(caption)
                        .font(.system(size: Theme.FontSize.caption, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.9))
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(Theme.Spacing.small)
                }
            }
        }
    }
}

#Preview {
    HStack(spacing: Theme.Spacing.medium) {
        WikiCoverView(coverURL: nil, tint: Color(hex: 0xE0A458), caption: "Elden Ring")
            .frame(width: 90, height: 90)
        WikiCoverView(coverURL: nil, tint: Color(hex: 0x2FA9D8), caption: "Subnautica")
            .frame(width: 130, height: 170)
    }
    .padding()
    .background(Color.grymBgDark)
}
