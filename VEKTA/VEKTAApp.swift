// Файл: VEKTAApp.swift

import SwiftUI

// Определим возможные экраны нашего приложения для навигации
enum AppScreen {
    case onboarding
    case login
    case forgotPassword // Добавим для примера, если будет нужно
    case register       // Добавим для примера
    case mainApp        // Экран после успешного логина
}

@main
struct VEKTAApp: App {
    // @State private var showOnboarding = true // Заменим на более гибкое управление экранами
    @State private var currentScreen: AppScreen
    @State private var hasCompletedOnboarding: Bool

    init() {
        // Проверяем, был ли онбординг уже пройден (загружаем из UserDefaults)
        let completed = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        self.hasCompletedOnboarding = completed
        
        if completed {
            // Если онбординг пройден, начинаем с логина
            _currentScreen = State(initialValue: .login)
        } else {
            // Иначе начинаем с онбординга
            _currentScreen = State(initialValue: .onboarding)
        }
    }

    var body: some Scene {
        WindowGroup {
            // Используем NavigationView или NavigationStack для глобальной навигации, если потребуется
            // Но для простого переключения корневых View можно обойтись ZStack или if/else
            
            switch currentScreen {
            case .onboarding:
                OnboardingFlowView {
                    // Онбординг завершен или пропущен
                    UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
                    self.hasCompletedOnboarding = true
                    withAnimation {
                        self.currentScreen = .login // Переходим на экран логина
                    }
                }
            case .login:
                LoginScreenView(
                    onLoginTap: { email, password in
                        // Здесь будет логика входа через Firebase
                        print("Login attempt with Email: \(email)")
                        // Пока просто переходим на главный экран для примера
                        withAnimation {
                            self.currentScreen = .mainApp
                        }
                    },
                    onForgotPasswordTap: {
                        print("Navigate to Forgot Password")
                        // withAnimation { self.currentScreen = .forgotPassword }
                    },
                    onRegisterTap: {
                        print("Navigate to Register")
                        // withAnimation { self.currentScreen = .register }
                    },
                    onShowOnboardingTap: {
                        // Сбрасываем флаг и возвращаемся на онбординг
                        UserDefaults.standard.set(false, forKey: "hasCompletedOnboarding")
                        self.hasCompletedOnboarding = false
                        withAnimation {
                            self.currentScreen = .onboarding
                        }
                    }
                )
            case .forgotPassword:
                // Заглушка для экрана восстановления пароля
                Text("Экран Восстановления Пароля")
                    .onTapGesture { withAnimation { self.currentScreen = .login } }
            case .register:
                // Заглушка для экрана регистрации
                Text("Экран Регистрации")
                    .onTapGesture { withAnimation { self.currentScreen = .login } }
            case .mainApp:
                // Заглушка для основного экрана приложения после логина
                // Замени на свой ContentView или главный экран приложения
                VStack {
                    Text("Главный экран приложения VEKTA!")
                    Button("Выйти (на экран логина)") {
                        withAnimation {
                            self.currentScreen = .login
                        }
                    }
                }
            }
        }
    }
}
