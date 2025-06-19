import SwiftUI

struct MyDeliveriesView: View {
    var body: some View {
        VStack {
            Text("Мои доставки")
                .font(.title)
                .padding()
            
            Text("Здесь будет список назначенных доставок")
                .foregroundColor(.gray)
            
            Spacer()
        }
        .navigationTitle("Доставки")
    }
}

struct DeliveryMapView: View {
    var body: some View {
        VStack {
            Text("Маршрут доставки")
                .font(.title)
                .padding()
            
            Text("Здесь будет карта с маршрутом")
                .foregroundColor(.gray)
            
            Spacer()
        }
        .navigationTitle("Маршрут")
    }
}

struct CourierEarningsView: View {
    var body: some View {
        VStack {
            Text("Мои заработки")
                .font(.title)
                .padding()
            
            Text("Здесь будет статистика заработков курьера")
                .foregroundColor(.gray)
            
            Spacer()
        }
        .navigationTitle("Заработки")
    }
}
