// Файл: LoginScreenView.swift

import SwiftUI

struct LoginScreenView: View {
    @State private var email = ""
    @State private var password = ""

    // Эти замыкания должны быть переданы из VEKTAApp.swift
    var onLoginTap: (String, String) -> Void
    var onForgotPasswordTap: () -> Void
    var onRegisterTap: () -> Void
    var onShowOnboardingTap: () -> Void
    
    var body: some View {
        ScrollView(.vertical) {
            VStack(spacing: 0) {
                
                VStack { // Логотип
                    Text("VEKTA")
                        .font(.system(size: 66, weight: .bold))
                        .tracking(0.5)
                        .foregroundColor(Color.textBlack) // Ожидается из Color+Extensions.swift
                   
                }
                .padding(.top, 60)
                .padding(.bottom, 48)

                VStack(spacing: 24) { // Форма входа
                    CustomTextField(placeholder: "Электронная почта", text: $email, keyboardType: .emailAddress)
                    CustomSecureField(placeholder: "Пароль", text: $password)

                    Button(action: { onLoginTap(email, password) }) {
                        Text("Войти")
                            .modifier(MainButtonModifier(backgroundColor: Color.brandGreen, textColor: Color.textWhite))
                    }

                    Button(action: onForgotPasswordTap) {
                        Text("Забыли пароль?")
                            .font(.system(size: 14))
                            .foregroundColor(Color.lightGrayText) // Ожидается из Color+Extensions.swift
                    }
                }
                .padding(.horizontal)

                OrDivider().padding(.vertical, 32) // Разделитель

                VStack(spacing: 24) { // Регистрация и инфо
                    Button(action: onRegisterTap) {
                        Text("Зарегистрироваться")
                            .modifier(MainButtonModifier(backgroundColor: .clear, textColor: Color.brandGreen, strokeColor: Color.brandGreen))
                    }
                    Text("Регистрация доступна для Селлеров и Курьеров.\nАдминистраторы создаются СуперАдмином.")
                        .font(.system(size: 12))
                        .foregroundColor(Color.placeholderGray) // Ожидается из Color+Extensions.swift
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                }
                .padding(.horizontal)

                Button(action: onShowOnboardingTap) { // Ссылка на онбординг
                    Text("← Посмотреть введение")
                        .font(.system(size: 14))
                        .foregroundColor(Color.brandGreen) // Ожидается из Color+Extensions.swift
                }
                .padding(.top, 32)
                .padding(.bottom, 40)
            }
            .frame(minHeight: UIScreen.main.bounds.height - (safeAreaInsets.top + safeAreaInsets.bottom))
            .padding(.horizontal)
        }
        .background(Color.textWhite.ignoresSafeArea()) // Ожидается из Color+Extensions.swift
        .navigationBarHidden(true)
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
    
    private var safeAreaInsets: UIEdgeInsets {
        (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first(where: { $0.isKeyWindow })?.safeAreaInsets ?? .zero
    }
}

// ... (остальные вспомогательные структуры MainButtonModifier, CustomTextField, CustomSecureField, OrDivider остаются такими же, как в твоем файле,
// просто убедись, что они используют цвета типа Color.backgroundGray, Color.veryLightGray и т.д., которые определены в Color+Extensions.swift)
// Я скопирую их из твоего файла для полноты, предполагая, что они верны, КРОМЕ ЦВЕТОВ:

struct MainButtonModifier: ViewModifier { // Как в твоем файле
    let backgroundColor: Color
    let textColor: Color
    var strokeColor: Color? = nil
    func body(content: Content) -> some View {
        content
            .font(.system(size: 18, weight: .medium))
            .foregroundColor(textColor)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(backgroundColor)
            .cornerRadius(16)
            .overlay(
                strokeColor.map { color in
                    RoundedRectangle(cornerRadius: 16).stroke(color, lineWidth: 2)
                }
            )
    }
}

struct CustomTextField: View { // Как в твоем файле, но цвета должны быть из Color+Extensions
    let placeholder: String
    @Binding var text: String
    let keyboardType: UIKeyboardType
    init(placeholder: String, text: Binding<String>, keyboardType: UIKeyboardType = .default) {
        self.placeholder = placeholder
        self._text = text
        self.keyboardType = keyboardType
    }
    var body: some View {
        TextField(placeholder, text: $text)
            .keyboardType(self.keyboardType)
            .autocapitalization(self.keyboardType == .emailAddress ? .none : .sentences)
            .padding(.horizontal, 24)
            .frame(height: 56)
            .background(Color.backgroundGray) // <- Убедись, что это Color.backgroundGray
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.veryLightGray, lineWidth: 1) // <- Убедись, что это Color.veryLightGray
            )
            .accentColor(Color.brandGreen)
            .foregroundColor(Color.textBlack)
    }
}

struct CustomSecureField: View { // Как в твоем файле, но цвета должны быть из Color+Extensions
    let placeholder: String
    @Binding var text: String
    var body: some View {
        SecureField(placeholder, text: $text)
            .padding(.horizontal, 24)
            .frame(height: 56)
            .background(Color.backgroundGray) // <- Убедись, что это Color.backgroundGray
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.veryLightGray, lineWidth: 1) // <- Убедись, что это Color.veryLightGray
            )
            .accentColor(Color.brandGreen)
            .foregroundColor(Color.textBlack)
    }
}

struct OrDivider: View { // Как в твоем файле, но цвета должны быть из Color+Extensions
    var body: some View {
        HStack {
            VStack { Divider().background(Color.veryLightGray) } // <- Убедись, что это Color.veryLightGray
            Text("Или")
                .font(.system(size: 14))
                .foregroundColor(Color.placeholderGray) // <- Убедись, что это Color.placeholderGray
                .padding(.horizontal, 10)
            VStack { Divider().background(Color.veryLightGray) } // <- Убедись, что это Color.veryLightGray
        }
    }
}

struct LoginScreenView_Previews: PreviewProvider { // Как в твоем файле
    static var previews: some View {
        Group {
            LoginScreenView(
                onLoginTap: {_,_ in print("Login Tapped") },
                onForgotPasswordTap: { print("Forgot Password Tapped") },
                onRegisterTap: { print("Register Tapped") },
                onShowOnboardingTap: { print("Show Onboarding Tapped") }
            )
            .environment(\.colorScheme, .light)
            .previewDisplayName("Light Mode")
            LoginScreenView(
                onLoginTap: {_,_ in print("Login Tapped") },
                onForgotPasswordTap: { print("Forgot Password Tapped") },
                onRegisterTap: { print("Register Tapped") },
                onShowOnboardingTap: { print("Show Onboarding Tapped") }
            )
            .environment(\.colorScheme, .dark)
            .previewDisplayName("Dark Mode")
        }
    }
}
