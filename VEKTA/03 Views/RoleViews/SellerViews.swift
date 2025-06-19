// MARK: - Seller Views
import SwiftUI

struct MyProductsView: View {
    var body: some View {
        VStack {
            Text("Мои товары")
                .font(.title)
                .padding()
            
            Text("Здесь будет список товаров селлера")
                .foregroundColor(.gray)
            
            Spacer()
        }
        .navigationTitle("Мои товары")
    }
}

struct MyOrdersView: View {
    var body: some View {
        VStack {
            Text("Мои заказы")
                .font(.title)
                .padding()
            
            Text("Здесь будет список заказов селлера")
                .foregroundColor(.gray)
            
            Spacer()
        }
        .navigationTitle("Мои заказы")
    }
}

struct KaspiIntegrationView: View {
    var body: some View {
        VStack {
            Text("Подключение Kaspi")
                .font(.title)
                .padding()
            
            Text("Здесь будет форма для ввода API ключа Kaspi")
                .foregroundColor(.gray)
            
            Spacer()
        }
        .navigationTitle("Kaspi")
    }
}

struct SellerAnalyticsView: View {
    var body: some View {
        VStack {
            Text("Моя аналитика")
                .font(.title)
                .padding()
            
            Text("Здесь будет аналитика по продажам селлера")
                .foregroundColor(.gray)
            
            Spacer()
        }
        .navigationTitle("Аналитика")
    }
}
