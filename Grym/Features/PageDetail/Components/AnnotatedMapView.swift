//
//  AnnotatedMapView.swift
//  Grym
//
//  Affiche une image de carte avec ses pins positionnés en coordonnées
//  relatives (0–1). Mode lecture seule ou édition (ajout au tap, drag, tap).
//

import SwiftUI
import UIKit

struct AnnotatedMapView: View {
    let image: UIImage
    @Binding var pins: [MapPin]
    var isEditable: Bool = false
    var onTapPin: (MapPin) -> Void = { _ in }

    private var aspect: CGFloat { max(image.size.width, 1) / max(image.size.height, 1) }
    private let mapSpace = "mapSpace"

    var body: some View {
        Image(uiImage: image)
            .resizable()
            .aspectRatio(aspect, contentMode: .fit)
            .overlay {
                GeometryReader { geo in
                    ZStack(alignment: .topLeading) {
                        if isEditable {
                            Color.clear
                                .contentShape(Rectangle())
                                .gesture(
                                    SpatialTapGesture()
                                        .onEnded { value in
                                            addPin(at: value.location, size: geo.size)
                                        }
                                )
                        }

                        ForEach($pins) { $pin in
                            MapPinMarker(label: pin.label)
                                .position(x: pin.x * geo.size.width,
                                          y: pin.y * geo.size.height)
                                .allowsHitTesting(isEditable)
                                .gesture(dragGesture($pin, size: geo.size))
                                .onTapGesture { onTapPin(pin) }
                        }
                    }
                    .coordinateSpace(name: mapSpace)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.medium, style: .continuous))
    }

    private func addPin(at location: CGPoint, size: CGSize) {
        pins.append(MapPin(x: clamp(location.x / size.width),
                           y: clamp(location.y / size.height)))
    }

    private func dragGesture(_ pin: Binding<MapPin>, size: CGSize) -> some Gesture {
        DragGesture(coordinateSpace: .named(mapSpace))
            .onChanged { value in
                pin.wrappedValue.x = clamp(value.location.x / size.width)
                pin.wrappedValue.y = clamp(value.location.y / size.height)
            }
    }

    private func clamp(_ v: CGFloat) -> Double { Double(min(max(v, 0), 1)) }
}

/// Marqueur d'un pin : pastille + libellé optionnel.
struct MapPinMarker: View {
    let label: String
    @Environment(\.theme) private var theme

    var body: some View {
        VStack(spacing: 2) {
            Image(systemName: "mappin.circle.fill")
                .font(.system(size: 26))
                .foregroundStyle(theme.accent)
                .background(Circle().fill(.white).padding(5))
                .shadow(color: .black.opacity(0.4), radius: 2, y: 1)

            if !label.isEmpty {
                Text(label)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, Theme.Spacing.xSmall)
                    .padding(.vertical, 1)
                    .background(Capsule().fill(.black.opacity(0.6)))
            }
        }
    }
}
