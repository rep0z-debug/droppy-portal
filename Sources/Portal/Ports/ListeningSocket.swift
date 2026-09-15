import Darwin
import Foundation

enum PortReach: Sendable, Hashable {
    case loopback
    case allInterfaces
    case interface(String)

    var reachesOtherDevices: Bool {
        switch self {
        case .loopback: return false
        case .allInterfaces, .interface: return true
        }
    }

    var boundAddress: String? {
        switch self {
        case .loopback, .allInterfaces: return nil
        case .interface(let address): return address
        }
    }

    var breadth: Int {
        switch self {
        case .loopback: return 0
        case .interface: return 1
        case .allInterfaces: return 2
        }
    }
}

struct ListeningSocket: Sendable, Hashable {
    let processID: pid_t
    let port: UInt16
    let reach: PortReach
    let processName: String
    let executablePath: String
    let startedAt: Date
}
