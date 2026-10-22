import DroppyKit
import SwiftUI

struct PortalWidget: View {
    @ObservedObject var droplet: PortalDroplet
    let context: ShelfWidgetContext

    private var height: CGFloat {
        context.availableSize.height > 0
            ? context.availableSize.height
            : WidgetMetrics.cardHeight(
                rows: droplet.servers.count,
                hasFootnote: droplet.hiddenPortNote != nil
            )
    }

    var body: some View {
        Group {
            if context.isCompact {
                ServerSummary(droplet: droplet, context: context)
            } else if let server = droplet.handoffServer {
                PhoneHandoff(droplet: droplet, server: server, context: context)
            } else {
                ServerList(
                    droplet: droplet,
                    availableHeight: height,
                    contentInsets: context.contentInsets
                )
            }
        }
        .padding(context.contentInsets)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .onAppear { droplet.surfaceDidAppear() }
        .onDisappear { droplet.surfaceDidDisappear() }
    }
}
