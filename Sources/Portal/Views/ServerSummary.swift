import DroppyKit
import SwiftUI

struct ServerSummary: View {
    @ObservedObject var droplet: PortalDroplet
    let context: ShelfWidgetContext

    var body: some View {
        VStack(alignment: .leading, spacing: DroppySpacing.sm) {
            WidgetHeader(title: "Portal")

            VStack(alignment: .leading, spacing: 2) {
                Text(verbatim: "\(droplet.servers.count)")
                    .font(.system(size: 28, weight: .semibold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(AdaptiveColors.notchSurfacePrimaryText)
                Text(droplet.runningSummary)
                    .font(.system(size: 11))
                    .foregroundStyle(AdaptiveColors.notchSurfaceTertiaryText)
            }

            if listedServers.isEmpty {
                Spacer(minLength: 0)
            } else {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(listedServers) { server in
                        HStack(spacing: DroppySpacing.xs) {
                            Text(server.runtime)
                                .font(.system(size: 12))
                                .foregroundStyle(AdaptiveColors.notchSurfaceTertiaryText)
                                .lineLimit(1)
                            Spacer(minLength: DroppySpacing.sm)
                            Text(verbatim: ":\(server.port)")
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .monospacedDigit()
                                .foregroundStyle(AdaptiveColors.notchSurfaceSecondaryText)
                        }
                        .frame(height: WidgetMetrics.compactRowHeight)
                    }
                    Spacer(minLength: 0)
                }
            }
        }
    }

    private var listedServers: [LocalServer] {
        let used = WidgetMetrics.chromeHeight + 45 + DroppySpacing.sm
        let room = context.availableSize.height - used
        let fits = Int((room / WidgetMetrics.compactRowHeight).rounded(.down))
        return Array(droplet.servers.prefix(max(0, fits)))
    }
}
