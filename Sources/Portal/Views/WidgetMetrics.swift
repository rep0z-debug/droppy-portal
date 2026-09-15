import DroppyKit
import SwiftUI

enum WidgetMetrics {
    static let headerHeight: CGFloat = 20
    static let rowHeight: CGFloat = 20
    static let compactRowHeight: CGFloat = 17
    static let footnoteHeight: CGFloat = 14
    static let listBottomInset: CGFloat = 2
    static let cornerSafeInset = DroppySpacing.xs
    static let visibleRowCeiling = 10
    static let shortestCard: CGFloat = 110

    static let codeSide: CGFloat = 88
    static let codeTileInset = DroppySpacing.xsm

    static var codeTileSide: CGFloat { codeSide + codeTileInset * 2 }

    static var chromeHeight: CGFloat {
        cornerSafeInset * 2 + headerHeight + DroppySpacing.sm
    }

    static var handoffCardHeight: CGFloat {
        chromeHeight + codeTileSide + DroppySpacing.sm
    }

    static func cardHeight(rows: Int, hasFootnote: Bool) -> CGFloat {
        let shown = min(rows, visibleRowCeiling)
        let list = shown > 0
            ? CGFloat(shown) * rowHeight + CGFloat(shown - 1) * DroppySpacing.xsm
            : 0
        let footnote = hasFootnote && rows <= visibleRowCeiling
            ? DroppySpacing.sm + footnoteHeight
            : 0
        return max(chromeHeight + list + footnote + listBottomInset, shortestCard)
    }
}
