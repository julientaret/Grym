//
//  WikiCoverView.swift
//  Grym
//
//  Cover d'un wiki : jaquette locale (offline) en priorité, sinon CDN IGDB
//  en lazy loading, sinon un dégradé teinté avec halo (repli visuel).
//

import SwiftUI

struct WikiCoverView: View {
    /// `image_id` IGDB de la jaquette ; `nil` = pas de cover connue.
    let imageId: String?
    let tint: Color
    var size: IGDBImageSize = .coverBig
    var cornerRadius: CGFloat = Theme.Radius.medium
    /// Titre optionnel imprimé sur le repli (rappelle les jaquettes maquette).
    var caption: String? = nil

    /// Fichier local si présent, sinon URL CDN reconstruite.
    private var coverURL: URL? {
        guard let imageId else { return nil }
        return CoverStore.existingLocalURL(for: imageId) ?? size.url(imageId: imageId)
    }

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
        WikiCoverView(imageId: nil, tint: Color(hex: 0xE0A458), caption: "Elden Ring")
            .frame(width: 90, height: 90)
        WikiCoverView(imageId: nil, tint: Color(hex: 0x2FA9D8), caption: "Subnautica")
            .frame(width: 130, height: 170)
    }
    .padding()
    .background(Color.grymBgDark)
}
