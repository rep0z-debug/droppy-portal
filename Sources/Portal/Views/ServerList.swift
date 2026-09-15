import DroppyKit
import SwiftUI

struct ServerList: View {
    @ObservedObject var droplet: PortalDroplet

    var body: some View {
        VStack(alignment: .leading, spacing: DroppySpacing.sm) {
            header

            if droplet.servers.isEmpty {
                quiet
                Spacer(minLength: 0)
            } else {
                list
                    .scrollIndicators(.never)
                    .scrollBounceBehavior(.basedOnSize)
                    .droppyFlatGlassControls()
            }
        }
    }

    private var header: some View {
        WidgetHeader(title: "Portal") {
            if droplet.servers.count > WidgetMetrics.visibleRowCeiling {
                Text(verbatim: "\(droplet.servers.count)")
                    .font(.system(size: 11, weight: .medium))
                    .monospacedDigit()
                    .foregroundStyle(AdaptiveColors.notchSurfaceTertiaryText)
            }

            Button {
                droplet.showsEveryPortBinding.wrappedValue.toggle()
            } label: {
                Image(systemName: droplet.showsEveryPort ? PortalGlyph.everyPort : PortalGlyph.devServersOnly)
            }
            .buttonStyle(DroppyCircleButtonStyle(size: 20))
            .accessibilityLabel(droplet.showsEveryPort ? "Show dev servers only" : "Show every port")
        }
    }

    @ViewBuilder
    private var list: some View {
        let rows = ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: DroppySpacing.xsm) {
                ForEach(droplet.servers) { server in
                    ServerRow(droplet: droplet, server: server)
                }

                if let footnote = droplet.hiddenPortNote {
                    Text(footnote)
                        .font(.system(size: 11))
                        .foregroundStyle(AdaptiveColors.notchSurfaceTertiaryText)
                        .lineLimit(1)
                        .frame(height: WidgetMetrics.footnoteHeight)
                        .padding(.top, DroppySpacing.xs)
                }
            }
            .padding(.bottom, WidgetMetrics.listBottomInset)
        }

        if droplet.servers.count > WidgetMetrics.visibleRowCeiling {
            rows.scrollEdgeFade()
        } else {
            rows
        }
    }

    private var quiet: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Nothing is listening")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(AdaptiveColors.notchSurfacePrimaryText)
            Text("Start a dev server and it shows up here.")
                .font(.system(size: 11))
                .foregroundStyle(AdaptiveColors.notchSurfaceTertiaryText)
        }
    }
}
