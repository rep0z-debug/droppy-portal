import Combine
import Darwin
import DroppyKit
import Foundation
import SwiftUI

@MainActor
public final class PortalDroplet: NSObject, ObservableObject, Droplet {
    public nonisolated static let id: DropletID = "portal"

    @Published private(set) var servers: [LocalServer] = []
    @Published private(set) var hiddenPortCount = 0
    @Published private(set) var localNetworkAddress: String?
    @Published private(set) var askedToQuit: Set<pid_t> = []
    @Published private(set) var announcement: NotchAnnouncement?
    @Published private(set) var recentlyCopied: LocalServer.Identity?
    @Published var handoffTarget: LocalServer.Identity? { didSet { resizeCard() } }

    let watcher = ServerWatcher()
    let activityState = CurrentValueSubject<LiveActivityState?, Never>(nil)
    let layoutInvalidation = PassthroughSubject<ShelfWidgetID, Never>()
    private(set) var host: DropletHost?
    private var quitRequests: [pid_t: Date] = [:]
    private var notchHold: Task<Void, Never>?
    private var copyFlash: Task<Void, Never>?
    private var cardHeight = WidgetMetrics.shortestCard

    public func activate(host: DropletHost) throws {
        self.host = host
        watcher.onChange = { [weak self] snapshot in self?.absorb(snapshot) }
        watcher.start(every: pollInterval, showingEveryPort: showsEveryPort)
        host.log.info("Portal is watching this account's listening ports")
    }

    public func deactivate() {
        watcher.stop()
        watcher.onChange = nil
        notchHold?.cancel()
        notchHold = nil
        copyFlash?.cancel()
        copyFlash = nil
        activityState.send(nil)
        host?.hud.dismiss(id: Self.announcementHUDIdentifier)
        servers = []
        hiddenPortCount = 0
        localNetworkAddress = nil
        handoffTarget = nil
        announcement = nil
        recentlyCopied = nil
        askedToQuit = []
        quitRequests.removeAll()
        host = nil
    }

    var newestServer: LocalServer? { servers.first }

    var handoffServer: LocalServer? {
        guard let handoffTarget else { return nil }
        return servers.first { $0.id == handoffTarget }
    }

    var hiddenPortNote: String? {
        guard hiddenPortCount > 0, !showsEveryPort else { return nil }
        return hiddenPortCount == 1 ? "1 other port hidden" : "\(hiddenPortCount) other ports hidden"
    }

    var widgetTraits: ShelfWidgetLayoutTraits {
        ShelfWidgetLayoutTraits(
            preferredSoloWidth: 420,
            preferredPairedWidth: 210,
            contentHeight: .fixed(cardHeight)
        )
    }

    func networkAddress(of server: LocalServer) -> String? {
        server.networkAddress(onNetwork: localNetworkAddress)
    }

    func willForceQuit(_ server: LocalServer) -> Bool {
        askedToQuit.contains(server.processID)
    }

    func didJustCopy(_ server: LocalServer) -> Bool {
        recentlyCopied == server.id
    }

    func rememberQuitRequest(for processID: pid_t) {
        quitRequests[processID] = Date().addingTimeInterval(Self.forceQuitGrace)
        askedToQuit.insert(processID)
    }

    func flashCopied(_ identity: LocalServer.Identity) {
        copyFlash?.cancel()
        recentlyCopied = identity
        copyFlash = Task { [weak self] in
            try? await Task.sleep(for: .seconds(Self.copyFlashSeconds))
            guard !Task.isCancelled else { return }
            self?.recentlyCopied = nil
        }
    }

    func releaseNotch() {
        notchHold?.cancel()
        notchHold = nil
        guard announcement != nil else { return }
        announcement = nil
        publishActivity()
    }

    private func absorb(_ snapshot: ServerSnapshot) {
        servers = snapshot.servers
        hiddenPortCount = snapshot.hiddenCount
        localNetworkAddress = snapshot.networkAddress

        if let handoffTarget, !servers.contains(where: { $0.id == handoffTarget }) {
            self.handoffTarget = nil
        }
        forgetStaleQuitRequests()
        resizeCard()

        var latest: NotchAnnouncement?
        if announcesArrivals, let arrival = snapshot.arrivals.first {
            latest = NotchAnnouncement(server: arrival, kind: .arrived)
        }
        if announcesDepartures, let departure = snapshot.departures.first {
            latest = NotchAnnouncement(server: departure, kind: .departed)
        }

        if let latest {
            announce(latest)
            if notchHoldSeconds > 0 { holdInNotch(latest) }
        } else if let announcement, announcement.kind == .arrived,
                  !servers.contains(where: { $0.id == announcement.server.id }) {
            releaseNotch()
        }
        publishActivity()
    }

    private func holdInNotch(_ next: NotchAnnouncement) {
        notchHold?.cancel()
        withAnimation(DroppyAnimation.state) { announcement = next }
        let seconds = notchHoldSeconds
        notchHold = Task { [weak self] in
            try? await Task.sleep(for: .seconds(seconds))
            guard !Task.isCancelled else { return }
            self?.releaseNotch()
        }
    }

    private func resizeCard() {
        let list = WidgetMetrics.cardHeight(rows: servers.count, hasFootnote: hiddenPortNote != nil)
        let showsCode = handoffServer.flatMap { networkAddress(of: $0) } != nil
        let height = showsCode ? max(list, WidgetMetrics.handoffCardHeight) : list
        guard height != cardHeight else { return }
        cardHeight = height
        layoutInvalidation.send(Self.widgetIdentifier)
    }

    private func forgetStaleQuitRequests() {
        let now = Date()
        let running = Set(servers.map(\.processID))
        quitRequests = quitRequests.filter { $0.value > now && running.contains($0.key) }
        let pending = Set(quitRequests.keys)
        if pending != askedToQuit { askedToQuit = pending }
    }

    private static let forceQuitGrace: TimeInterval = 8
    private static let copyFlashSeconds: TimeInterval = 1.6
}
