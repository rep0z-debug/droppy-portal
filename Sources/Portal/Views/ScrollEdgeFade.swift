import DroppyKit
import SwiftUI

private struct ScrollEdgeFade: ViewModifier {
    let fadeLength: CGFloat

    @State private var fadesTop = false
    @State private var fadesBottom = true

    private struct ClippedEdges: Equatable {
        var top: Bool
        var bottom: Bool
    }

    func body(content: Content) -> some View {
        if #available(macOS 15.0, *) {
            content
                .onScrollGeometryChange(for: ClippedEdges.self) { geometry in
                    let offset = geometry.contentOffset.y + geometry.contentInsets.top
                    let overflow = geometry.contentSize.height
                        + geometry.contentInsets.top
                        + geometry.contentInsets.bottom
                        - geometry.containerSize.height
                    return ClippedEdges(top: offset > 1, bottom: overflow - offset > 1)
                } action: { _, edges in
                    fadesTop = edges.top
                    fadesBottom = edges.bottom
                }
                .mask(fade)
        } else {
            content.mask(fade)
        }
    }

    private var fade: some View {
        GeometryReader { proxy in
            let ramp = min(fadeLength / max(proxy.size.height, 1), 0.5)
            LinearGradient(
                stops: [
                    Gradient.Stop(color: .black.opacity(fadesTop ? 0 : 1), location: 0),
                    Gradient.Stop(color: .black, location: ramp),
                    Gradient.Stop(color: .black, location: 1 - ramp),
                    Gradient.Stop(color: .black.opacity(fadesBottom ? 0 : 1), location: 1)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
        .animation(DroppyAnimation.hoverQuick, value: fadesTop)
        .animation(DroppyAnimation.hoverQuick, value: fadesBottom)
        .allowsHitTesting(false)
    }
}

extension View {
    func scrollEdgeFade(_ fadeLength: CGFloat = 14) -> some View {
        modifier(ScrollEdgeFade(fadeLength: fadeLength))
    }
}
