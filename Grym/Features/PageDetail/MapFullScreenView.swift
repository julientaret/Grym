//
//  MapFullScreenView.swift
//  Grym
//
//  Visionneuse plein écran d'une carte annotée (lecture seule) : l'image
//  occupe tout l'écran, safe areas comprises, et suit la rotation de
//  l'appareil pour être lue en paysage.
//

import SwiftUI
import UIKit

struct MapFullScreenView: View {
    let image: UIImage
    let pins: [MapPin]

    @EnvironmentObject private var localization: LocalizationManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color.black
            AnnotatedMapView(image: image, pins: .constant(pins))
            closeButton
        }
        .ignoresSafeArea()
        // Le tap n'importe où referme : geste attendu d'une visionneuse.
        .onTapGesture { dismiss() }
    }

    private var closeButton: some View {
        Button { dismiss() } label: {
            Image(systemName: "xmark")
                .font(.system(size: Theme.FontSize.body, weight: .bold))
                .foregroundStyle(.white)
                .padding(Theme.Spacing.medium)
                .background(Circle().fill(.black.opacity(0.5)))
        }
        .padding(Theme.Spacing.medium)
        .accessibilityLabel(localization.string(.mapExitFullScreen))
    }
}

#Preview {
    MapFullScreenView(
        image: UIImage(systemName: "map") ?? UIImage(),
        pins: [MapPin(x: 0.3, y: 0.4, label: "Camp")]
    )
    .environmentObject(LocalizationManager())
    .environment(\.theme, GrymBlueTheme())
}
