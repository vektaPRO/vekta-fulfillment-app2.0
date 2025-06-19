// MARK: - Warehouse Admin Views
import SwiftUI

struct ReceivingView: View {
    var body: some View {
        VStack {
            Text("Приемка товаров")
                .font(.title)
                .padding()
            
            Text("Здесь будет сканер QR-кодов и форма приемки")
                .foregroundColor(.gray)
            
            Spacer()
        }
        .navigationTitle("Приемка")
    }
}

struct ShippingView: View {
    var body: some View {
        VStack {
            Text("Отгрузка заказов")
                .font(.title)
                .padding()
            
            Text("Здесь будет список заказов готовых к отгрузке")
                .foregroundColor(.gray)
            
            Spacer()
        }
        .navigationTitle("Отгрузка")
    }
}

struct InventoryView: View {
    var body: some View {
        VStack {
            Text("Управление товарами")
                .font(.title)
                .padding()
            
            Text("Здесь будет список всех товаров на складе")
                .foregroundColor(.gray)
            
            Spacer()
        }
        .navigationTitle("Товары")
    }
}

struct CourierManagementView: View {
    var body: some View {
        VStack {
            Text("Управление курьерами")
                .font(.title)
                .padding()
            
            Text("Здесь будет список курьеров и назначение доставок")
                .foregroundColor(.gray)
            
            Spacer()
        }
        .navigationTitle("Курьеры")
    }
}
