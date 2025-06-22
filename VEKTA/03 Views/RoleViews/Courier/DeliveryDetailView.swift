import SwiftUI
import FirebaseFunctions

class DeliveryDetailViewModel: ObservableObject {
    private let functions = Functions.functions()

    func sendSmsCode(orderId: String) {
        let data: [String: Any] = ["orderId": orderId]
        functions.httpsCallable("sendSmsCode").call(data) { result, error in
            if let error = error {
                print("❌ Ошибка отправки SMS-кода: \(error.localizedDescription)")
            } else {
                print("📲 SMS-код отправлен для заказа \(orderId)")
            }
        }
    }

    func markDelivered(orderId: String, smsCode: String) {
        let data: [String: Any] = ["orderId": orderId, "smsCode": smsCode]
        functions.httpsCallable("confirmSmsCode").call(data) { result, error in
            if let error = error {
                print("❌ Ошибка подтверждения доставки: \(error.localizedDescription)")
            } else {
                print("✅ Доставка подтверждена для заказа \(orderId)")
            }
        }
    }
}

struct DeliveryDetailView: View {
    let orderId: String
    @StateObject private var viewModel = DeliveryDetailViewModel()

    @State private var showSmsAlert = false
    @State private var smsCode = ""

    var body: some View {
        VStack(spacing: 20) {
            Text("Детали заказа \(orderId)")
                .font(.title2)

            Button("Отправить клиенту SMS-код") {
                viewModel.sendSmsCode(orderId: orderId)
            }
            .font(.headline)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.kaspiBlue)
            .foregroundColor(.white)
            .cornerRadius(12)

            Button("Подтвердить доставку") {
                showSmsAlert = true
            }
            .font(.headline)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.brandGreen)
            .foregroundColor(.white)
            .cornerRadius(12)
            .alert("Введите SMS-код", isPresented: $showSmsAlert) {
                TextField("0000", text: $smsCode)
                    .keyboardType(.numberPad)
                Button("Подтвердить") {
                    viewModel.markDelivered(orderId: orderId, smsCode: smsCode)
                    smsCode = ""
                }
                Button("Отмена", role: .cancel) {}
            }
        }
        .padding()
        .navigationTitle("Доставка")
    }
}

struct DeliveryDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DeliveryDetailView(orderId: "123456")
        }
    }
}
