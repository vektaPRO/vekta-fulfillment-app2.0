import SwiftUI

struct WarehouseListView: View {
    var body: some View {
        VStack {
            Text("Управление складами")
                .font(.title)
                .padding()
            
            Text("Здесь будет список всех складов")
                .foregroundColor(.gray)
            
            Spacer()
        }
        .navigationTitle("Склады")
    }
}

struct UserManagementView: View {
    var body: some View {
        VStack {
            Text("Управление пользователями")
                .font(.title)
                .padding()
            
            Text("Здесь будет список всех пользователей")
                .foregroundColor(.gray)
            
            Spacer()
        }
        .navigationTitle("Пользователи")
    }
}

struct AnalyticsView: View {
    var body: some View {
        VStack {
            Text("Аналитика VEKTA")
                .font(.title)
                .padding()
            
            Text("Здесь будет общая аналитика по всем складам")
                .foregroundColor(.gray)
            
            Spacer()
        }
        .navigationTitle("Аналитика")
    }
}
