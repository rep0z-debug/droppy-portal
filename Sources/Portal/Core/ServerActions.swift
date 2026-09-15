import Darwin
import DroppyKit
import Foundation

extension PortalDroplet {
    var canCopyAddresses: Bool { host?.isGranted(.clipboardWrite) ?? false }

    func openInBrowser(_ server: LocalServer) {
        guard let url = server.localURL else { return }
        guard host?.workspace.open(url) == true else {
            host?.feedback.play(.failure)
            return
        }
        host?.feedback.play(.tick)
    }

    func copyLocalAddress(of server: LocalServer) {
        copy("http://\(server.localAddress)", from: server)
    }

    func copyNetworkAddress(of server: LocalServer) {
        guard let address = networkAddress(of: server) else { return }
        copy("http://\(address)", from: server)
    }

    func showOnPhone(_ server: LocalServer) {
        handoffTarget = handoffTarget == server.id ? nil : server.id
    }

    func closeHandoff() {
        handoffTarget = nil
    }

    func stop(_ server: LocalServer) {
        guard !server.isThisApp else {
            host?.log.notice("refused to signal Droppy itself on port \(server.port)")
            host?.feedback.play(.failure)
            return
        }

        let force = willForceQuit(server)
        switch ProcessSignals.stop(server.processID, startedAt: server.startedAt, force: force) {
        case .delivered:
            if !force { rememberQuitRequest(for: server.processID) }
            host?.feedback.play(.success)
            host?.log.info("sent \(force ? "SIGKILL" : "SIGTERM") to \(server.runtime) on port \(server.port)")
        case .gone:
            host?.log.info("\(server.runtime) on port \(server.port) had already exited")
        case .refused:
            host?.feedback.play(.failure)
            host?.log.notice("not allowed to signal the process on port \(server.port)")
        }
    }

    private func copy(_ text: String, from server: LocalServer) {
        guard let host, host.isGranted(.clipboardWrite), host.workspace.copyToPasteboard(text) else {
            host?.feedback.play(.failure)
            return
        }
        host.feedback.play(.tick)
        flashCopied(server.id)
    }
}
