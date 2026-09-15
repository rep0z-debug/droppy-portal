import Combine
import DroppyKit
import SwiftUI

extension PortalDroplet: LiveActivityProviding {
    public var liveActivityState: AnyPublisher<LiveActivityState?, Never> {
        activityState.eraseToAnyPublisher()
    }

    public func makeCompactLeading() -> AnyView {
        let glyph = announcement?.glyph ?? PortalGlyph.mark
        return AnyView(
            ZStack {
                Image(systemName: glyph)
                    .font(.system(size: DroppyLiveActivityMetrics.iconSize, weight: .medium))
                    .foregroundStyle(AdaptiveColors.notchSurfacePrimaryText)
                    .id(glyph)
                    .transition(DroppyTransition.compactLeading)
            }
            .animation(DroppyAnimation.state, value: glyph)
        )
    }

    public func makeCompactTrailing() -> AnyView {
        let port = announcement.map { ":\($0.server.port)" } ?? ""
        return AnyView(
            ZStack {
                Text(verbatim: port)
                    .font(.system(size: DroppyLiveActivityMetrics.labelFontSize, weight: .medium, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(AdaptiveColors.notchSurfacePrimaryText)
                    .id(port)
                    .transition(DroppyTransition.compactTrailing)
            }
            .animation(DroppyAnimation.state, value: port)
        )
    }

    public func makeExpanded(context: LiveActivityContext) -> AnyView {
        AnyView(
            HStack(spacing: DroppySpacing.md) {
                Text(announcement?.server.runtime ?? "")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(AdaptiveColors.notchSurfacePrimaryText)
                Text(announcement?.kind == .departed ? "closed" : "is up")
                    .font(.system(size: 11))
                    .foregroundStyle(AdaptiveColors.notchSurfaceTertiaryText)
                Spacer(minLength: 0)
                Text(verbatim: announcement.map { ":\($0.server.port)" } ?? "")
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(AdaptiveColors.notchSurfaceSecondaryText)
            }
            .lineLimit(1)
            .frame(width: context.availableWidth, height: DroppyLiveActivityMetrics.cardContentHeight)
        )
    }

    public func makeCompanionCompact(context: CompactLiveActivityContext) -> AnyView {
        makeCompactTrailing()
    }

    func publishActivity() {
        guard let announcement else {
            if activityState.value != nil { activityState.send(nil) }
            return
        }
        let next = LiveActivityState(
            priority: 150,
            accessibilityTitle: announcement.spokenLabel,
            isInteractive: false
        )
        if activityState.value != next { activityState.send(next) }
    }

    var runningSummary: String {
        servers.count == 1 ? "server running" : "servers running"
    }
}
