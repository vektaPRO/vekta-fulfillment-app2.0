import SwiftUI

struct QRCodeView: View {
    let data: String
    var body: some View {
        if let image = QRService.shared.generateQRCode(from: data) {
            Image(uiImage: image)
                .interpolation(.none)
                .resizable()
                .scaledToFit()
        } else {
            Text("❌ QR не сгенерирован")
        }
    }
}
