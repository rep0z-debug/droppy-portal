import AppKit
import CoreImage
import CoreImage.CIFilterBuiltins
import Foundation

@MainActor
enum QRCode {
    private static let renderer = CIContext(options: [.useSoftwareRenderer: false])

    static func image(encoding text: String, fitting side: CGFloat) -> NSImage? {
        let generator = CIFilter.qrCodeGenerator()
        generator.message = Data(text.utf8)
        generator.correctionLevel = "M"

        guard let symbol = generator.outputImage, symbol.extent.width > 0 else { return nil }
        let magnification = max(1, (side * 3 / symbol.extent.width).rounded(.down))
        let enlarged = symbol.transformed(by: CGAffineTransform(scaleX: magnification, y: magnification))
        guard let rendered = renderer.createCGImage(enlarged, from: enlarged.extent) else { return nil }
        return NSImage(cgImage: rendered, size: CGSize(width: side, height: side))
    }
}
