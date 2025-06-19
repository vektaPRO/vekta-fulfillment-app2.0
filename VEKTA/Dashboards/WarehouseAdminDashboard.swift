import SwiftUI
import FirebaseAuth

struct WarehouseAdminDashboard: View {
    let user: UserModel
    @StateObject private var shipmentManager = ShipmentManager()
    @StateObject private var productManager = ProductManager()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Заголовок с названием склада
                HStack {
                    VStack(alignment: .leading) {
                        Text("Склад: Главный VEKTA") // TODO: Получать из warehouseId
                            .font(.title2)
                            .fontWeight(.semibold)
                        Text(user.displayName)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    Button("Выйти") {
                        try? Auth.auth().signOut()
                    }
                }
                .padding()
                
                // Статистика склада
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                    StatCard(title: "Новые заказы", value: "5", icon: "tray.and.arrow.down", color: .orange)
                    StatCard(title: "Готово к отгрузке", value: "12", icon: "checkmark.circle", color: .green)
                    StatCard(title: "В доставке", value: "8", icon: "truck", color: .blue)
                    StatCard(title: "Товаров на складе", value: "156", icon: "cube.box", color: .purple)
                }
                .padding(.horizontal)
                
                // Быстрые действия
                VStack(spacing: 12) {
                    NavigationLink(destination: ReceivingView()) {
                        ActionButton(title: "Приемка товаров", icon: "tray.and.arrow.down.fill", color: .green)
                    }
                    
                    NavigationLink(destination: ShippingView()) {
                        ActionButton(title: "Отгрузка заказов", icon: "tray.and.arrow.up.fill", color: .blue)
                    }
                    
                    NavigationLink(destination: InventoryView()) {
                        ActionButton(title: "Управление товарами", icon: "cube.box.fill", color: .purple)
                    }
                    
                    NavigationLink(destination: CourierManagementView()) {
                        ActionButton(title: "Управление курьерами", icon: "person.fill.car", color: .orange)
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationBarHidden(true)
        }
    }
}
