import DroppyKit
import SwiftUI

struct PortalWidget: View {
    @ObservedObject var droplet: PortalDroplet
    let context: ShelfWidgetContext

    var body: some View {
        Group {
            if context.isCompact {
                ServerSummary(droplet: droplet, context: context)
            } else if let server = droplet.handoffServer {
                PhoneHandoff(droplet: droplet, server: server, context: context)
            } else {
                ServerList(droplet: droplet, availableHeight: context.availableSize.height)
            }
        }
        .padding(context.contentInsets)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .onAppear { droplet.surfaceDidAppear() }
        .onDisappear { droplet.surfaceDidDisappear() }
    }
}
