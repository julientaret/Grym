//
//  WikiHeroBanner.swift
//  Grym
//
//  Bandeau illustré en tête du détail d'un wiki : illustration IGDB pleine
//  largeur, fondue vers le bas pour se raccorder au fond du thème.
//

import SwiftUI

struct WikiHeroBanner: View {
    /// `image_id` IGDB de l'illustration à afficher.
    let imageId: String
    /// Teinte de repli, le temps du chargement réseau.
    let tint: Color

    /// Hauteur totale, barre de navigation comprise : le bandeau passe dessous.
    var height: CGFloat = 280

    /// Le fondu est un masque (et non un dégradé posé par-dessus) : le bandeau
    /// se raccorde ainsi à n'importe quel fond, quel que soit le thème actif.
    private let fadeMask = LinearGradient(
        stops: [
            .init(color: .white, location: 0),
            .init(color: .white, location: 0.5),
            .init(color: .clear, location: 1)
        ],
        startPoint: .top,
        endPoint: .bottom
    )

    var body: some View {
        Color.clear
            .frame(height: height)
            .overlay {
                AsyncImage(url: IGDBImageSize.screenshotBig.url(imageId: imageId)) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().scaledToFill()
                    default:
                        placeholder
                    }
                }
            }
            .clipped()
            .mask(fadeMask)
            .allowsHitTesting(false)
    }

    private var placeholder: some View {
        LinearGradient(
            colors: [tint.opacity(0.35), .black.opacity(0.4)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

#Preview {
    VStack(spacing: 0) {
        WikiHeroBanner(imageId: "ar3m1o", tint: Color(hex: 0xE0A458))
        Spacer()
    }
    .background(Color.grymBgDark)
}
