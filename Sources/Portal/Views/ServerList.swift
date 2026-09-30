import DroppyKit
import SwiftUI

struct ServerList: View {
    @ObservedObject var droplet: PortalDroplet
    let availableHeight: CGFloat

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
            if moreCount > 0 {
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

    private var fittingRowCount: Int {
        let chrome = WidgetMetrics.chromeHeight + WidgetMetrics.listBottomInset
        let footnote = droplet.hiddenPortNote != nil ? DroppySpacing.sm + WidgetMetrics.footnoteHeight : 0
        let remaining = availableHeight - chrome - footnote
        guard remaining > 0 else { return 0 }
        let perRow = WidgetMetrics.rowHeight + DroppySpacing.xsm
        return max(0, Int((remaining + DroppySpacing.xsm) / perRow))
    }

    private var shownServers: [LocalServer] {
        let total = droplet.servers.count
        let capacity = fittingRowCount
        guard total > capacity else { return droplet.servers }
        return Array(droplet.servers.prefix(max(0, capacity - 1)))
    }

    private var moreCount: Int {
        droplet.servers.count - shownServers.count
    }

    @ViewBuilder
    private var list: some View {
        let shown = shownServers
        let overflow = moreCount

        let rows = ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: DroppySpacing.xsm) {
                ForEach(shown) { server in
                    ServerRow(droplet: droplet, server: server)
                }

                if overflow > 0 {
                    Text(overflow == 1 ? "and 1 more" : "and \(overflow) more")
                        .font(.system(size: 11))
                        .foregroundStyle(AdaptiveColors.notchSurfaceTertiaryText)
                        .frame(height: WidgetMetrics.rowHeight)
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

        if overflow > 0 || shown.count > WidgetMetrics.visibleRowCeiling {
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
