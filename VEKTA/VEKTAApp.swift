import SwiftUI
import Firebase
import FirebaseAuth
import Combine

// MARK: - App Screen State
enum AppScreen {
    case onboarding
    case login
    case register
    case forgotPassword
}

// MARK: - Enhanced App State
class AppState: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var isLoadingAuth: Bool = true
    @Published var currentScreen: AppScreen = .onboarding
    
    // ИСПРАВЛЕНО: Убираем @StateObject и используем обычное свойство
    let roleManager = RoleManager()
    
    private var authStateHandler: AuthStateDidChangeListenerHandle?
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupRoleManagerBinding()
        setupAuthenticationListener()
    }
    
    deinit {
        removeAuthenticationListener()
    }
    
    // ДОБАВЛЕНО: Привязка к изменениям RoleManager
    private func setupRoleManagerBinding() {
        roleManager.objectWillChange
            .sink { [weak self] in
                DispatchQueue.main.async {
                    self?.objectWillChange.send()
                }
            }
            .store(in: &cancellables)
    }
    
    func setupAuthenticationListener() {
        if authStateHandler == nil {
            authStateHandler = Auth.auth().addStateDidChangeListener { [weak self] auth, user in
                DispatchQueue.main.async {
                    print("🔐 Auth state changed. User: \(user?.uid ?? "nil")")
                    
                    withAnimation(.easeInOut) {
                        self?.isAuthenticated = (user != nil)
                        self?.isLoadingAuth = false
                        
                        // Загружаем роль пользователя, если он авторизован
                        if let user = user {
                            print("🔍 Fetching user role for: \(user.uid)")
                            self?.roleManager.fetchUserRole(for: user.uid)
                        } else {
                            print("🧹 Clearing user data")
                            self?.roleManager.clearCurrentUser()
                        }
                    }
                }
            }
        }
    }
    
    func removeAuthenticationListener() {
        if let handler = authStateHandler {
            Auth.auth().removeStateDidChangeListener(handler)
            self.authStateHandler = nil
        }
    }
    
    func signInUser(email: String, password: String) {
        print("🔐 Attempting to sign in: \(email)")
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Login error: \(error.localizedDescription)")
                    // TODO: Показать пользователю Alert с ошибкой
                    return
                }
                print("✅ User signed in successfully: \(authResult?.user.uid ?? "unknown")")
            }
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            roleManager.clearCurrentUser()
        } catch {
            print("Ошибка выхода: \(error.localizedDescription)")
        }
    }
}

// MARK: - Main App Entry Point
@main
struct VEKTAApp: App {
    @StateObject private var appState = AppState()
    
    init() {
        FirebaseApp.configure()
        print("🔥 Firebase configured successfully")
        
        // Проверяем текущего пользователя
        if let currentUser = Auth.auth().currentUser {
            print("👤 Current user found: \(currentUser.uid)")
        } else {
            print("👤 No current user found")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            Group {
                if appState.isLoadingAuth || appState.roleManager.isLoadingUser {
                    LoadingView()
                } else if appState.isAuthenticated {
                    // Проверяем, загружена ли роль пользователя
                    if let user = appState.roleManager.currentUser {
                        DashboardFactory.createDashboard(for: user.role, user: user)
                            .environmentObject(appState)
                    } else if let errorMessage = appState.roleManager.errorMessage {
                        ErrorView(message: errorMessage) {
                            appState.signOut()
                        }
                    } else {
                        LoadingView()
                    }
                } else {
                    // Неавторизованный пользователь
                    switch appState.currentScreen {
                    case .onboarding:
                        OnboardingFlowView {
                            withAnimation { appState.currentScreen = .login }
                        }
                    case .login:
                        LoginScreenView(
                            onLoginTap: { email, password in
                                appState.signInUser(email: email, password: password)
                            },
                            onForgotPasswordTap: {
                                withAnimation { appState.currentScreen = .forgotPassword }
                            },
                            onRegisterTap: {
                                withAnimation { appState.currentScreen = .register }
                            },
                            onShowOnboardingTap: {
                                withAnimation { appState.currentScreen = .onboarding }
                            }
                        )
                    case .forgotPassword:
                        ForgotPasswordView {
                            withAnimation { appState.currentScreen = .login }
                        }
                    case .register:
                        RegistrationView {
                            withAnimation { appState.currentScreen = .login }
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Supporting Views
struct LoadingView: View {
    var body: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Загрузка...")
                .font(.headline)
                .foregroundColor(.gray)
            
            // Показываем текущее состояние
            if let currentUser = Auth.auth().currentUser {
                Text("Загружаем данные пользователя...")
                    .font(.caption)
                    .foregroundColor(.gray)
                Text("UID: \(currentUser.uid)")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

struct ErrorView: View {
    let message: String
    let onRetry: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 60))
                .foregroundColor(.red)
            
            Text("Ошибка")
                .font(.title)
                .fontWeight(.bold)
            
            Text(message)
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button("Повторить") {
                onRetry()
            }
            .font(.system(size: 18, weight: .medium))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .background(Color.brandGreen)
            .cornerRadius(16)
            .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

// MARK: - Placeholder Views for Missing Screens
struct ForgotPasswordView: View {
    let onBack: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Восстановление пароля")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Функция будет реализована позже")
                .foregroundColor(.gray)
            
            Button("Назад к входу") {
                onBack()
            }
            .foregroundColor(.brandGreen)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

struct RegistrationView: View {
    let onBack: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Регистрация")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Регистрация доступна только через администратора")
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
                .padding(.horizontal)
            
            Button("Назад к входу") {
                onBack()
            }
            .foregroundColor(.brandGreen)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

// MARK: - Manager Classes (заглушки для компиляции)
class WarehouseManager: ObservableObject {
    @Published var warehouses: [WarehouseModel] = []
    
    func loadWarehouses() {
        // TODO: Загрузка складов из Firestore
    }
}

class UserManager: ObservableObject {
    @Published var users: [UserModel] = []
    
    func loadUsers() {
        // TODO: Загрузка пользователей из Firestore
    }
}

class ShipmentManager: ObservableObject {
    @Published var shipments: [ShipmentModel] = []
    
    func loadShipments() {
        // TODO: Загрузка отгрузок из Firestore
    }
}

class ProductManager: ObservableObject {
    @Published var products: [ProductModel] = []
    
    func loadProducts() {
        // TODO: Загрузка товаров из Firestore
    }
}
