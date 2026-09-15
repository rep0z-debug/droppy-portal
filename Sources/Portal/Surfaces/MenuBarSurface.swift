import DroppyKit
import SwiftUI

extension PortalDroplet: MenuBarExtraProviding {
    public func makeMenuBarExtra() -> MenuBarExtraDescriptor? {
        guard showsMenuBarItem else { return nil }
        return MenuBarExtraDescriptor(title: "Portal", systemImage: PortalGlyph.mark) { [weak self] in
            guard let self else { return AnyView(EmptyView()) }
            return AnyView(MenuBarList(droplet: self))
        }
    }
}
