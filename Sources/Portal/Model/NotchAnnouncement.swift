import Foundation

struct NotchAnnouncement: Equatable, Sendable {
    enum Kind: Equatable, Sendable {
        case arrived
        case departed
    }

    let server: LocalServer
    let kind: Kind

    var glyph: String {
        kind == .arrived ? PortalGlyph.mark : PortalGlyph.closed
    }

    var spokenLabel: String {
        kind == .arrived
            ? "\(server.localAddress) is up"
            : "\(server.localAddress) closed"
    }
}
