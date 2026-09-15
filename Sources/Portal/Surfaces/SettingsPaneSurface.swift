import DroppyKit
import SwiftUI

extension PortalDroplet: SettingsPaneProviding {
    public func makeSettingsPane(context: SettingsPaneContext) -> AnyView {
        AnyView(PortalSettingsPane(droplet: self))
    }

    public var settingsSearchEntries: [SettingsSearchEntry] {
        [
            SettingsSearchEntry(title: "Show all ports", keywords: ["port", "localhost", "server", "filter"]),
            SettingsSearchEntry(title: "Announce new servers", keywords: ["hud", "notch", "announce"]),
            SettingsSearchEntry(title: "Announce servers that close", keywords: ["hud", "notch", "closed"]),
            SettingsSearchEntry(title: "Keep it in the notch", keywords: ["live activity", "notch", "seconds"]),
            SettingsSearchEntry(title: "Show a menu bar item", keywords: ["menu bar", "status item"]),
            SettingsSearchEntry(title: "Check for changes", keywords: ["refresh", "poll", "interval"])
        ]
    }
}
