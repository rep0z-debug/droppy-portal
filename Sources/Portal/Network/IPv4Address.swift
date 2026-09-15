import Foundation

enum IPv4Address {
    static func text(networkOrder value: UInt32) -> String {
        let host = UInt32(bigEndian: value)
        return "\(host >> 24 & 0xff).\(host >> 16 & 0xff).\(host >> 8 & 0xff).\(host & 0xff)"
    }

    static func isUnspecified(networkOrder value: UInt32) -> Bool {
        value == 0
    }

    static func isLoopback(networkOrder value: UInt32) -> Bool {
        UInt32(bigEndian: value) >> 24 == 127
    }

    static func isLinkLocal(networkOrder value: UInt32) -> Bool {
        UInt32(bigEndian: value) >> 16 == 0xa9fe
    }
}
