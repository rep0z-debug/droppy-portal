import Darwin
import Foundation

struct ServerSnapshot: Sendable {
    let servers: [LocalServer]
    let hiddenCount: Int
    let networkAddress: String?
    let arrivals: [LocalServer]
    let departures: [LocalServer]
}

@MainActor
final class ServerWatcher {
    var onChange: ((ServerSnapshot) -> Void)?

    private var loop: Task<Void, Never>?
    private var sweep: Task<Void, Never>?
    private var announced: [LocalServer.Identity: LocalServer] = [:]
    private var reportsArrivals = false
    private var interval: TimeInterval = 1
    private var showsEveryPort = false

    func start(every seconds: TimeInterval, showingEveryPort everything: Bool) {
        stop()
        interval = seconds
        showsEveryPort = everything
        loop = Task { [weak self] in
            while !Task.isCancelled {
                guard let self else { return }
                self.look()
                try? await Task.sleep(for: .seconds(self.interval))
            }
        }
    }

    func stop() {
        loop?.cancel()
        loop = nil
        sweep?.cancel()
        sweep = nil
        announced.removeAll()
        reportsArrivals = false
    }

    func setInterval(_ seconds: TimeInterval) {
        guard seconds != interval else { return }
        interval = seconds
    }

    func showEveryPort(_ everything: Bool) {
        guard everything != showsEveryPort else { return }
        showsEveryPort = everything
        look()
    }

    private func look() {
        guard sweep == nil else { return }
        sweep = Task { [weak self] in
            let reading = await Task.detached(priority: .utility) {
                PortReading(sockets: ListeningPorts.current(), networkAddress: LocalNetworkAddress.current())
            }.value
            guard !Task.isCancelled, let self else { return }
            self.sweep = nil
            self.report(reading)
        }
    }

    private func report(_ reading: PortReading) {
        let everything = LocalServer.gathered(from: reading.sockets)
        let developmentServers = everything.filter(\.isDevelopmentServer)
        let listable = showsEveryPort ? everything : developmentServers

        let present = Set(developmentServers.map(\.id))
        let arrivals: [LocalServer]
        let departures: [LocalServer]
        if reportsArrivals {
            arrivals = developmentServers.filter { announced[$0.id] == nil }
            departures = announced
                .filter { !present.contains($0.key) }
                .values
                .sorted { $0.startedAt > $1.startedAt }
        } else {
            arrivals = []
            departures = []
            reportsArrivals = true
        }
        announced = Dictionary(uniqueKeysWithValues: developmentServers.map { ($0.id, $0) })

        onChange?(
            ServerSnapshot(
                servers: listable,
                hiddenCount: everything.count - listable.count,
                networkAddress: reading.networkAddress,
                arrivals: arrivals,
                departures: departures
            )
        )
    }
}

private struct PortReading: Sendable {
    let sockets: [ListeningSocket]
    let networkAddress: String?
}
