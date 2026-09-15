import Combine
import DroppyKit
import SwiftUI

extension PortalDroplet: ShelfWidgetProviding {
    public var widgetDescriptors: [ShelfWidgetDescriptor] {
        [
            ShelfWidgetDescriptor(
                id: Self.widgetIdentifier,
                title: "Portal",
                systemImage: PortalGlyph.mark,
                layoutTraits: widgetTraits,
                searchKeywords: ["localhost", "port", "server", "dev"]
            )
        ]
    }

    public func makeWidgetView(_ id: ShelfWidgetID, context: ShelfWidgetContext) -> AnyView {
        AnyView(PortalWidget(droplet: self, context: context))
    }

    static let widgetIdentifier: ShelfWidgetID = "servers"
}

extension PortalDroplet: ShelfWidgetDynamicLayoutProviding {
    public func currentLayoutTraits(for id: ShelfWidgetID) -> ShelfWidgetLayoutTraits? {
        id == Self.widgetIdentifier ? widgetTraits : nil
    }

    public var shelfWidgetLayoutInvalidationPublisher: AnyPublisher<ShelfWidgetID, Never> {
        layoutInvalidation.eraseToAnyPublisher()
    }
}
