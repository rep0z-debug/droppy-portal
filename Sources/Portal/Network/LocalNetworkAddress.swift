import Darwin
import Foundation

enum LocalNetworkAddress {
    static func current() -> String? {
        var head: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&head) == 0, let first = head else { return nil }
        defer { freeifaddrs(head) }

        var fallback: String?
        for interface in sequence(first: first, next: { $0.pointee.ifa_next }) {
            let flags = Int32(interface.pointee.ifa_flags)
            guard flags & IFF_UP != 0, flags & IFF_RUNNING != 0, flags & IFF_LOOPBACK == 0 else { continue }
            guard let address = interface.pointee.ifa_addr, address.pointee.sa_family == UInt8(AF_INET) else { continue }

            let name = String(cString: interface.pointee.ifa_name)
            guard name.hasPrefix("en") else { continue }

            let value = address.withMemoryRebound(to: sockaddr_in.self, capacity: 1) { $0.pointee.sin_addr.s_addr }
            guard !IPv4Address.isUnspecified(networkOrder: value),
                  !IPv4Address.isLoopback(networkOrder: value),
                  !IPv4Address.isLinkLocal(networkOrder: value) else { continue }

            let text = IPv4Address.text(networkOrder: value)
            if name == "en0" { return text }
            if fallback == nil { fallback = text }
        }
        return fallback
    }
}
