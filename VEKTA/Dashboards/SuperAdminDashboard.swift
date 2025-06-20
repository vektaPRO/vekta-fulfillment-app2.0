import SwiftUI
import FirebaseAuth

struct SuperAdminDashboard: View {
    let user: UserModel
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Заголовок
                HStack {
                    VStack(alignment: .leading) {
                        Text("Добро пожаловать, \(user.displayName)")
                            .font(.title2)
                            .fontWeight(.semibold)
                        Text("Супер Администратор")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    Button("Выйти") {
                        try? Auth.auth().signOut()
                    }
                }
                .padding()
                
                // Статистика
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                    StatCard(title: "Всего складов", value: "5", icon: "building.2")
                    StatCard(title: "Пользователей", value: "127", icon: "person.3")
                    StatCard(title: "Оборот", value: "2.5М ₸", icon: "chart.line.uptrend.xyaxis")
                    StatCard(title: "Заказов", value: "1,234", icon: "cart")
                }
                .padding(.horizontal)
                
                // Действия
                VStack(spacing: 12) {
                    NavigationLink(destination: WarehouseListView()) {
                        ActionButton(title: "Управление складами", icon: "building.2.fill", color: .blue)
                    }
                    
                    NavigationLink(destination: UserManagementView()) {
                        ActionButton(title: "Управление пользователями", icon: "person.3.fill", color: .green)
                    }
                    
                    NavigationLink(destination: AnalyticsView()) {
                        ActionButton(title: "Аналитика VEKTA", icon: "chart.bar.fill", color: .purple)
                    }
                    
                    ActionButton(title: "Настройки системы", icon: "gearshape.fill", color: .orange)
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationBarHidden(true)
        }
    }
}
