import UIKit
import CoreImage

/// Service responsible for QR code related utilities.
final class QRService {
    /// Shared singleton instance
    static let shared = QRService()

    private let context = CIContext()

    private init() {}

    /// Generates a QR code image from the provided string using CoreImage.
    func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: .utf8)
        guard let filter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue("Q", forKey: "inputCorrectionLevel")
        guard let outputImage = filter.outputImage else { return nil }
        let scaledImage = outputImage.transformed(by: CGAffineTransform(scaleX: 10, y: 10))
        if let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) {
            return UIImage(cgImage: cgImage)
        }
        return nil
    }

    /// Returns a string representation for the given product to use in a QR code.
    func dataForProduct(_ product: ProductModel) -> String {
        return "product:\(product.id ?? "")"
    }

    /// Returns a string representation for the given receiving product to use in a QR code.
    func dataForProduct(_ product: ReceivingProduct) -> String {
        return "product:\(product.id)"
    }

    /// Returns a string representation for the given shipment to use in a QR code.
    func dataForShipment(_ shipment: ShipmentModel) -> String {
        return "shipment:\(shipment.id ?? "")"
    }
}
