import DroppyKit
import SwiftUI

extension PortalDroplet: HUDPresenting {
    static let announcementHUDIdentifier = "portal.announcement"

    func announce(_ announcement: NotchAnnouncement) {
        guard let host, host.isGranted(.hud) else { return }
        let glyph = announcement.glyph
        let port = ":\(announcement.server.port)"
        let request = DropletHUDRequest(
            id: Self.announcementHUDIdentifier,
            duration: 2,
            priority: .normal,
            accessibilityLabel: announcement.spokenLabel
        ) {
            HStack(spacing: 0) {
                Image(systemName: glyph)
                    .font(.system(size: DroppyLiveActivityMetrics.iconSize, weight: .semibold))
                Spacer(minLength: 0)
                Text(verbatim: port)
                    .font(.system(size: DroppyLiveActivityMetrics.labelFontSize, weight: .semibold, design: .rounded))
                    .monospacedDigit()
            }
            .frame(maxWidth: .infinity)
            .foregroundStyle(AdaptiveColors.notchSurfacePrimaryText)
        }
        _ = host.hud.present(request)
    }
}
