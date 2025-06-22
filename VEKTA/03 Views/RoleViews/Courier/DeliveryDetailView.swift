import SwiftUI

class DeliveryDetailViewModel: ObservableObject {
    func sendSmsCode(orderId: String) {
        // Здесь будет вызов API Kaspi для отправки SMS через заглушку
        AlertManager.shared.show(error: AppError.custom("Отправляем SMS-код для заказа: \(orderId)"))
    }

    func markDelivered(orderId: String, smsCode: String) {
        // Здесь будет подтверждение доставки через API
        AlertManager.shared.show(error: AppError.custom("Подтверждаем доставку заказа \(orderId) с кодом \(smsCode)"))
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
