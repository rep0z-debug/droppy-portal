import DroppyKit
import Foundation
import SwiftUI

extension PortalDroplet {
    private enum Stored {
        static let showsEveryPort = "showsEveryPort"
        static let announcesArrivals = "announcesArrivals"
        static let announcesDepartures = "announcesDepartures"
        static let notchHoldSeconds = "notchHoldSeconds"
        static let pollInterval = "pollInterval"
        static let showsMenuBarItem = "showsMenuBarItem"
    }

    static let pollIntervalRange: ClosedRange<Double> = 0.5...5
    static let notchHoldRange: ClosedRange<Double> = 0...30

    var showsEveryPort: Bool {
        host?.preferences.value(forKey: Stored.showsEveryPort, default: true) ?? true
    }

    var announcesArrivals: Bool {
        host?.preferences.value(forKey: Stored.announcesArrivals, default: true) ?? true
    }

    var announcesDepartures: Bool {
        host?.preferences.value(forKey: Stored.announcesDepartures, default: false) ?? false
    }

    var announcesDeparturesBinding: Binding<Bool> {
        Binding(
            get: { self.announcesDepartures },
            set: { announces in
                self.objectWillChange.send()
                self.host?.preferences.setValue(announces, forKey: Stored.announcesDepartures)
                if !announces, self.announcement?.kind == .departed { self.releaseNotch() }
            }
        )
    }

    var notchHoldSeconds: Double {
        let stored = host?.preferences.value(forKey: Stored.notchHoldSeconds, default: 0.0) ?? 0
        return stored.clamped(to: Self.notchHoldRange)
    }

    var pollInterval: Double {
        let stored = host?.preferences.value(forKey: Stored.pollInterval, default: 1.0) ?? 1
        return stored.clamped(to: Self.pollIntervalRange)
    }

    var showsMenuBarItem: Bool {
        host?.preferences.value(forKey: Stored.showsMenuBarItem, default: true) ?? true
    }

    var showsMenuBarItemBinding: Binding<Bool> {
        Binding(
            get: { self.showsMenuBarItem },
            set: { shows in
                self.objectWillChange.send()
                self.host?.preferences.setValue(shows, forKey: Stored.showsMenuBarItem)
            }
        )
    }

    var showsEveryPortBinding: Binding<Bool> {
        Binding(
            get: { self.showsEveryPort },
            set: { everything in
                self.objectWillChange.send()
                self.host?.preferences.setValue(everything, forKey: Stored.showsEveryPort)
                self.watcher.showEveryPort(everything)
            }
        )
    }

    var announcesArrivalsBinding: Binding<Bool> {
        Binding(
            get: { self.announcesArrivals },
            set: { announces in
                self.objectWillChange.send()
                self.host?.preferences.setValue(announces, forKey: Stored.announcesArrivals)
            }
        )
    }

    var notchHoldSecondsBinding: Binding<Double> {
        Binding(
            get: { self.notchHoldSeconds },
            set: { seconds in
                let clamped = seconds.clamped(to: Self.notchHoldRange)
                self.objectWillChange.send()
                self.host?.preferences.setValue(clamped, forKey: Stored.notchHoldSeconds)
                if clamped == 0 { self.releaseNotch() }
            }
        )
    }

    var pollIntervalBinding: Binding<Double> {
        Binding(
            get: { self.pollInterval },
            set: { seconds in
                let clamped = seconds.clamped(to: Self.pollIntervalRange)
                self.objectWillChange.send()
                self.host?.preferences.setValue(clamped, forKey: Stored.pollInterval)
                self.watcher.setInterval(clamped)
            }
        )
    }
}

private extension Double {
    func clamped(to range: ClosedRange<Double>) -> Double {
        min(max(self, range.lowerBound), range.upperBound)
    }
}
