import Darwin
import Foundation

struct LocalServer: Identifiable, Hashable, Sendable {
    struct Identity: Hashable, Sendable {
        let processID: pid_t
        let port: UInt16
    }

    let id: Identity
    let reach: PortReach
    let processName: String
    let runtime: String
    let isDevelopmentServer: Bool
    let startedAt: Date

    var processID: pid_t { id.processID }
    var port: UInt16 { id.port }
    var isThisApp: Bool { id.processID == getpid() }
    var localAddress: String { "localhost:\(port)" }
    var localURL: URL? { URL(string: "http://\(localAddress)") }

    func networkAddress(onNetwork network: String?) -> String? {
        guard reach.reachesOtherDevices else { return nil }
        guard let host = reach.boundAddress ?? network else { return nil }
        return "\(host):\(port)"
    }
}

extension LocalServer {
    static func gathered(from sockets: [ListeningSocket]) -> [LocalServer] {
        var byIdentity: [Identity: LocalServer] = [:]
        for socket in sockets {
            let identity = Identity(processID: socket.processID, port: socket.port)
            if let seen = byIdentity[identity], seen.reach.breadth >= socket.reach.breadth { continue }
            let runtime = ServerRuntime.label(forProcessNamed: socket.processName)
            let looksLikeDevelopment = ServerRuntime.isDevelopmentPort(socket.port)
                && !ServerRuntime.isSystemBinary(at: socket.executablePath)
            byIdentity[identity] = LocalServer(
                id: identity,
                reach: socket.reach,
                processName: socket.processName,
                runtime: runtime ?? socket.processName,
                isDevelopmentServer: runtime != nil || looksLikeDevelopment,
                startedAt: socket.startedAt
            )
        }
        return byIdentity.values.sorted { first, second in
            if first.startedAt != second.startedAt { return first.startedAt > second.startedAt }
            return first.port < second.port
        }
    }
}
