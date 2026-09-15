import DroppyKit
import SwiftUI

struct ServerRow: View {
    @ObservedObject var droplet: PortalDroplet
    let server: LocalServer

    var body: some View {
        HStack(spacing: DroppySpacing.xsm) {
            Text(server.runtime)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(AdaptiveColors.notchSurfacePrimaryText)
                .lineLimit(1)
                .truncationMode(.tail)

            Text(verbatim: ":\(server.port)")
                .font(.system(size: 13, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(AdaptiveColors.notchSurfaceSecondaryText)
                .layoutPriority(1)

            Spacer(minLength: DroppySpacing.sm)

            Text(Uptime.short(since: server.startedAt))
                .font(.system(size: 11))
                .monospacedDigit()
                .foregroundStyle(AdaptiveColors.notchSurfaceTertiaryText)
                .layoutPriority(1)

            controls
        }
        .frame(height: WidgetMetrics.rowHeight)
    }

    private var copied: Bool { droplet.didJustCopy(server) }

    private var controls: some View {
        HStack(spacing: DroppySpacing.xs) {
            Button {
                droplet.openInBrowser(server)
            } label: {
                Image(systemName: PortalGlyph.openInBrowser)
            }
            .buttonStyle(DroppyCircleButtonStyle(size: 20))
            .accessibilityLabel("Open \(server.localAddress) in your browser")

            if droplet.canCopyAddresses {
                Button {
                    droplet.copyLocalAddress(of: server)
                } label: {
                    Image(systemName: copied ? PortalGlyph.copied : PortalGlyph.copyAddress)
                        .contentTransition(.symbolEffect(.replace))
                }
                .buttonStyle(DroppyCircleButtonStyle(size: 20))
                .scaleEffect(copied ? 1.15 : 1)
                .animation(DroppyAnimation.bounce, value: copied)
                .accessibilityLabel("Copy \(server.localAddress)")
            }

            Button {
                droplet.showOnPhone(server)
            } label: {
                Image(systemName: PortalGlyph.phone)
            }
            .buttonStyle(DroppyCircleButtonStyle(size: 20))
            .accessibilityLabel("Open port \(server.port) on your phone")

            if !server.isThisApp {
                Button {
                    droplet.stop(server)
                } label: {
                    Image(systemName: PortalGlyph.stop)
                }
                .buttonStyle(
                    DroppyCircleButtonStyle(
                        size: 20,
                        destructive: true,
                        solidFill: nil,
                        foregroundColorOverride: nil
                    )
                )
                .accessibilityLabel(
                    droplet.willForceQuit(server)
                        ? "Force quit \(server.runtime) on port \(server.port)"
                        : "Quit \(server.runtime) on port \(server.port)"
                )
            }
        }
    }
}
