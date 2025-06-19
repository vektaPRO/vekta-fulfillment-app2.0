// MARK: - SuperAdminDashboard.swift
import SwiftUI

struct SuperAdminDashboard: View {
    let user: UserModel
    @StateObject private var warehouseManager = WarehouseManager()
    @StateObject private var userManager = UserManager()
    
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
                    .foregroundColor(.red)
                }
                .padding()
                
                // Статистика
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                    StatCard(title: "Складов", value: "\(warehouseManager.warehouses.count)", icon: "building.2")
                    StatCard(title: "Пользователей", value: "\(userManager.users.count)", icon: "person.3")
                    StatCard(title: "Активных заказов", value: "0", icon: "box")
                    StatCard(title: "Доходы VEKTA", value: "0 ₸", icon: "tenge")
                }
                .padding(.horizontal)
                
                // Действия
                VStack(spacing: 12) {
                    NavigationLink(destination: WarehouseListView()) {
                        ActionButton(title: "Управление складами", icon: "building.2", color: .blue)
                    }
                    
                    NavigationLink(destination: UserManagementView()) {
                        ActionButton(title: "Управление пользователями", icon: "person.3", color: .green)
                    }
                    
                    NavigationLink(destination: AnalyticsView()) {
                        ActionButton(title: "Аналитика и отчеты", icon: "chart.bar", color: .purple)
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            warehouseManager.loadWarehouses()
            userManager.loadUsers()
        }
    }
}
