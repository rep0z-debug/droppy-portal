import DroppyKit
import SwiftUI

struct WidgetHeader<Trailing: View>: View {
    let title: String
    var systemImage: String = PortalGlyph.mark
    @ViewBuilder var trailing: () -> Trailing

    var body: some View {
        HStack(spacing: DroppySpacing.xsm) {
            Image(systemName: systemImage)
                .font(.system(size: 12, weight: .medium))
            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .lineLimit(1)
            Spacer(minLength: DroppySpacing.sm)
            trailing()
        }
        .frame(height: WidgetMetrics.headerHeight)
        .foregroundStyle(AdaptiveColors.notchSurfaceSecondaryText)
    }
}

extension WidgetHeader where Trailing == EmptyView {
    init(title: String, systemImage: String = PortalGlyph.mark) {
        self.init(title: title, systemImage: systemImage) { EmptyView() }
    }
}
