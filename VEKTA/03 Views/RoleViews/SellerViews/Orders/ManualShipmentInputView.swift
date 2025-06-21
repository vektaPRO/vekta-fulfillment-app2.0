import SwiftUI

struct ManualShipmentInputView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var shipmentId: String = ""
    let onSubmit: (String) -> Void

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                TextField("ID приемки", text: $shipmentId)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                Button("Найти") {
                    onSubmit(shipmentId)
                    presentationMode.wrappedValue.dismiss()
                }
                .disabled(shipmentId.isEmpty)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.brandGreen)
                .foregroundColor(.white)
                .cornerRadius(12)
                .padding()

                Spacer()
            }
            .navigationTitle("Поиск приемки")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Закрыть") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}
