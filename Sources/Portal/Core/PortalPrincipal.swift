import DroppyKit
import Foundation

@objc(PortalPrincipal)
public final class PortalPrincipal: NSObject, DropletPrincipal {
    public override init() { super.init() }

    @MainActor public func makeDroplet() -> AnyObject { PortalDroplet() }
}
