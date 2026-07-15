//
//  PhotoViewerView.swift
//  Grym
//
//  Visionneuse plein écran d'une photo : pinch-to-zoom, double-tap
//  et déplacement (pan) quand l'image est zoomée.
//

import SwiftUI

struct PhotoViewerView: View {
    let url: URL

    @EnvironmentObject private var localization: LocalizationManager
    @Environment(\.dismiss) private var dismiss

    @State private var scale: CGFloat = 1
    @GestureState private var pinchScale: CGFloat = 1
    @State private var offset: CGSize = .zero
    @GestureState private var dragOffset: CGSize = .zero

    private var effectiveScale: CGFloat { max(scale * pinchScale, 1) }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color.black.ignoresSafeArea()

            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().scaledToFit()
                        .scaleEffect(effectiveScale)
                        .offset(x: offset.width + dragOffset.width,
                                y: offset.height + dragOffset.height)
                        .gesture(magnification)
                        .simultaneousGesture(pan)
                        .onTapGesture(count: 2) { toggleZoom() }
                case .failure:
                    Image(systemName: "photo")
                        .font(.system(size: Theme.FontSize.largeTitle))
                        .foregroundStyle(.white.opacity(0.5))
                default:
                    ProgressView().tint(.white)
                }
            }
            .ignoresSafeArea()

            closeButton
        }
        .statusBarHidden()
    }

    // MARK: Gestes

    private var magnification: some Gesture {
        MagnificationGesture()
            .updating($pinchScale) { value, state, _ in state = value }
            .onEnded { value in
                scale = min(max(scale * value, 1), 5)
                if scale == 1 { withAnimation(.easeOut) { offset = .zero } }
            }
    }

    private var pan: some Gesture {
        DragGesture()
            .updating($dragOffset) { value, state, _ in
                if effectiveScale > 1 { state = value.translation }
            }
            .onEnded { value in
                guard effectiveScale > 1 else { return }
                offset.width += value.translation.width
                offset.height += value.translation.height
            }
    }

    private func toggleZoom() {
        withAnimation(.spring(duration: 0.25)) {
            if scale > 1 {
                scale = 1
                offset = .zero
            } else {
                scale = 2.5
            }
        }
    }

    // MARK: Bouton fermer

    private var closeButton: some View {
        Button { dismiss() } label: {
            Image(systemName: "xmark")
                .font(.system(size: Theme.FontSize.body, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 40, height: 40)
                .background(Circle().fill(.black.opacity(0.45)))
        }
        .padding(Theme.Spacing.large)
        .accessibilityLabel(localization.string(.commonClose))
    }
}
