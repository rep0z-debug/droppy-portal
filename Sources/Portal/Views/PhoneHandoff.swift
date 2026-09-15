import AppKit
import DroppyKit
import SwiftUI

struct PhoneHandoff: View {
    @ObservedObject var droplet: PortalDroplet
    let server: LocalServer
    let context: ShelfWidgetContext

    @State private var code: NSImage?

    private var codeSide: CGFloat {
        let room = context.availableSize.height
            - WidgetMetrics.chromeHeight
            - DroppySpacing.sm
            - WidgetMetrics.codeTileInset * 2
        return max(56, min(WidgetMetrics.codeSide, room))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DroppySpacing.sm) {
            WidgetHeader(title: headline) {
                Button {
                    droplet.closeHandoff()
                } label: {
                    Image(systemName: PortalGlyph.close)
                }
                .buttonStyle(DroppyCircleButtonStyle(size: 20))
                .accessibilityLabel("Back to the list")
            }

            if let address = droplet.networkAddress(of: server) {
                reachable(at: address)
            } else if server.reach.reachesOtherDevices {
                note(
                    title: "No Wi-Fi address",
                    detail: "This Mac is not on a network another device can reach."
                )
            } else {
                note(
                    title: "Only this Mac can reach it",
                    detail: "\(server.runtime) is listening on 127.0.0.1. A server has to listen on 0.0.0.0 before another device can open it."
                )
            }

            Spacer(minLength: 0)
        }
    }

    private func reachable(at address: String) -> some View {
        HStack(alignment: .top, spacing: DroppySpacing.md) {
            codeTile(for: address)

            VStack(alignment: .leading, spacing: DroppySpacing.xs) {
                Text(verbatim: address)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(AdaptiveColors.notchSurfacePrimaryText)
                    .lineLimit(1)

                Text("Scan it with your phone, on the same Wi-Fi.")
                    .font(.system(size: 11))
                    .foregroundStyle(AdaptiveColors.notchSurfaceTertiaryText)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer(minLength: DroppySpacing.xs)

                if droplet.canCopyAddresses {
                    Button(droplet.didJustCopy(server) ? "Copied" : "Copy address") {
                        droplet.copyNetworkAddress(of: server)
                    }
                    .buttonStyle(DroppyQuietButtonStyle(size: .small))
                    .contentTransition(.opacity)
                    .animation(DroppyAnimation.state, value: droplet.didJustCopy(server))
                }
            }
            .frame(height: codeSide + WidgetMetrics.codeTileInset * 2, alignment: .topLeading)
        }
    }

    private func codeTile(for address: String) -> some View {
        Group {
            if let code {
                Image(nsImage: code)
                    .interpolation(.none)
                    .resizable()
                    .frame(width: codeSide, height: codeSide)
            } else {
                Color.clear.frame(width: codeSide, height: codeSide)
            }
        }
        .padding(WidgetMetrics.codeTileInset)
        .background(
            RoundedRectangle(cornerRadius: DroppyRadius.small, style: .continuous)
                .fill(Color.white)
        )
        .accessibilityLabel("QR code for http://\(address)")
        .task(id: address) {
            code = QRCode.image(encoding: "http://\(address)", fitting: WidgetMetrics.codeSide)
        }
    }

    private var headline: String {
        server.reach.reachesOtherDevices
            ? "Port \(server.port) on your phone"
            : "Port \(server.port) is local"
    }

    private func note(title: String, detail: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(AdaptiveColors.notchSurfacePrimaryText)
            Text(detail)
                .font(.system(size: 11))
                .foregroundStyle(AdaptiveColors.notchSurfaceTertiaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
