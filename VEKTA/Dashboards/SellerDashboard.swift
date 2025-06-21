// MARK: - Fix 3: Исправленный SellerDashboard.swift
import SwiftUI
import FirebaseAuth

struct SellerDashboard: View {
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
                        Text("Селлер")
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
                    StatCard(title: "Мои товары", value: "45", icon: "cube.box")
                    StatCard(title: "Заказы сегодня", value: "12", icon: "cart")
                    StatCard(title: "Выручка", value: "156,000 ₸", icon: "tenge")
                    StatCard(title: "Прибыль", value: "45,000 ₸", icon: "chart.line.uptrend.xyaxis")
                }
                .padding(.horizontal)
                
                // Действия
                VStack(spacing: 12) {
                    NavigationLink(destination: CreateReceivingOrderView()) {
                        ActionButton(title: "Создать приемку", icon: "tray.and.arrow.down.fill", color: .blue)
                    }
                    
                    NavigationLink(destination: MyOrdersView()) {
                        ActionButton(title: "Мои заказы", icon: "list.bullet.rectangle", color: .green)
                    }
                    
                    NavigationLink(destination: KaspiIntegrationView()) {
                        ActionButton(title: "Подключить Kaspi", icon: "link", color: .orange)
                    }
                    
                    NavigationLink(destination: SellerAnalyticsView()) {
                        ActionButton(title: "Моя аналитика", icon: "chart.bar.fill", color: .purple)
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationBarHidden(true)
        }
    }
}
