import DroppyKit
import SwiftUI

struct MenuBarList: View {
    @ObservedObject var droplet: PortalDroplet

    private static let width: CGFloat = 300
    private static let height: CGFloat = 168
    private static let rowHeight: CGFloat = 24
    private static let controlSize: CGFloat = 18

    var body: some View {
        VStack(alignment: .leading, spacing: DroppySpacing.xsm) {
            header
            list
        }
        .droppyFlatGlassControls()
        .padding(.horizontal, DroppySpacing.md)
        .padding(.vertical, DroppySpacing.sm)
        .frame(width: Self.width, height: Self.height, alignment: .top)
    }

    private var header: some View {
        HStack(spacing: DroppySpacing.xsm) {
            Text(summary)
                .font(.system(size: 11))
                .foregroundStyle(AdaptiveColors.secondaryTextAuto)
            Spacer(minLength: DroppySpacing.sm)
            Button {
                droplet.showsEveryPortBinding.wrappedValue.toggle()
            } label: {
                Image(systemName: droplet.showsEveryPort ? PortalGlyph.everyPort : PortalGlyph.devServersOnly)
            }
            .buttonStyle(DroppyCircleButtonStyle(size: Self.controlSize))
            .help(droplet.showsEveryPort ? "Showing every port" : "Showing dev servers")
            .accessibilityLabel(droplet.showsEveryPort ? "Show dev servers only" : "Show every port")
        }
        .frame(height: WidgetMetrics.headerHeight)
    }

    private var list: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(droplet.servers) { server in
                    row(for: server)
                }
            }
        }
        .scrollIndicators(.never)
        .scrollBounceBehavior(.basedOnSize)
        .scrollEdgeFade()
        .frame(maxHeight: .infinity, alignment: .top)
    }

    private var summary: String {
        switch droplet.servers.count {
        case 0: return "Nothing is listening"
        case 1: return "1 server running"
        default: return "\(droplet.servers.count) servers running"
        }
    }

    private func row(for server: LocalServer) -> some View {
        let copied = droplet.didJustCopy(server)
        return HStack(spacing: DroppySpacing.xs) {
            Text(server.runtime)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(AdaptiveColors.primaryTextAuto)
                .lineLimit(1)
                .truncationMode(.tail)

            Text(verbatim: ":\(server.port)")
                .font(.system(size: 12, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(AdaptiveColors.secondaryTextAuto)
                .layoutPriority(1)

            Spacer(minLength: DroppySpacing.sm)

            Button {
                droplet.openInBrowser(server)
            } label: {
                Image(systemName: PortalGlyph.openInBrowser)
            }
            .buttonStyle(DroppyCircleButtonStyle(size: Self.controlSize))
            .help("Open in your browser")
            .accessibilityLabel("Open \(server.localAddress) in your browser")

            if droplet.canCopyAddresses {
                Button {
                    droplet.copyLocalAddress(of: server)
                } label: {
                    Image(systemName: copied ? PortalGlyph.copied : PortalGlyph.copyAddress)
                        .contentTransition(.symbolEffect(.replace))
                }
                .buttonStyle(DroppyCircleButtonStyle(size: Self.controlSize))
                .scaleEffect(copied ? 1.15 : 1)
                .animation(DroppyAnimation.bounce, value: copied)
                .help(copied ? "Copied" : "Copy the address")
                .accessibilityLabel("Copy \(server.localAddress)")
            }

            if !server.isThisApp {
                Button {
                    droplet.stop(server)
                } label: {
                    Image(systemName: PortalGlyph.stop)
                }
                .buttonStyle(
                    DroppyCircleButtonStyle(
                        size: Self.controlSize,
                        destructive: true,
                        solidFill: nil,
                        foregroundColorOverride: nil
                    )
                )
                .help(droplet.willForceQuit(server) ? "Press again to force quit" : "Quit this process")
                .accessibilityLabel("Quit \(server.runtime) on port \(server.port)")
            }
        }
        .frame(height: Self.rowHeight)
    }
}
