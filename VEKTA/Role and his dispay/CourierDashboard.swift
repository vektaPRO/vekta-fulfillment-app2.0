struct CourierDashboard: View {
    let user: UserModel
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Добро пожаловать, \(user.displayName)")
                            .font(.title2)
                            .fontWeight(.semibold)
                        Text("Курьер")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    Button("Выйти") {
                        try? Auth.auth().signOut()
                    }
                }
                .padding()
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                    StatCard(title: "Назначено", value: "8", icon: "tray.full")
                    StatCard(title: "Доставлено", value: "25", icon: "checkmark.circle")
                    StatCard(title: "Заработано", value: "12,500 ₸", icon: "tenge")
                    StatCard(title: "Рейтинг", value: "4.8", icon: "star.fill")
                }
                .padding(.horizontal)
                
                VStack(spacing: 12) {
                    NavigationLink(destination: MyDeliveriesView()) {
                        ActionButton(title: "Мои доставки", icon: "truck.box.fill", color: .blue)
                    }
                    
                    NavigationLink(destination: DeliveryMapView()) {
                        ActionButton(title: "Маршрут доставки", icon: "map.fill", color: .green)
                    }
                    
                    NavigationLink(destination: CourierEarningsView()) {
                        ActionButton(title: "Мои заработки", icon: "chart.line.uptrend.xyaxis", color: .purple)
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationBarHidden(true)
        }
    }
}
