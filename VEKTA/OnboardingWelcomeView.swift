// Файл: OnboardingWelcomeView.swift (бывший SwiftUIView.swift)

import SwiftUI

// !!! УДАЛИ ЛОКАЛЬНОЕ РАСШИРЕНИЕ COLOR ОТСЮДА, ЕСЛИ ОНО БЫЛО !!!
// Оно теперь в Color+Extensions.swift

struct OnboardingWelcomeView: View {
    var onSkip: () -> Void
    var onNext: () -> Void

    var body: some View {
        VStack {
            // 1. Кнопка "Пропустить"
            HStack {
                Spacer()
                Button("Пропустить") {
                    onSkip()
                }
                .foregroundColor(Color.gray) // Стандартный серый для этой кнопки ок
                .font(.system(size: 14, weight: .medium))
            }
            .padding(.top)
            .padding(.horizontal)

            Spacer()

            // 2. Основной контент
            VStack(spacing: 24) {
                Image(systemName: "dial.max.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .foregroundColor(Color.brandGreen) // Из Color+Extensions.swift
                    .padding(.bottom, 20)

                Text("VEKTA 2.0: Ваш Центр\nФулфилмента в Кармане")
                    .font(.system(size: 30, weight: .light))
                    .foregroundColor(Color.textBlack) // Из Color+Extensions.swift (был Color.black)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)

                Text("Автоматизируйте приёмку, отгрузку и аналитику для вашего онлайн-бизнеса с Kaspi.")
                    .font(.system(size: 17, weight: .regular))
                    .foregroundColor(Color.lightGrayText) // Из Color+Extensions.swift
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
            }
            .padding(.horizontal)

            Spacer()

            // 3. Нижняя секция
            VStack(spacing: 20) {
                HStack(spacing: 8) {
                    Circle()
                        .fill(Color.brandGreen) // Из Color+Extensions.swift
                        .frame(width: 8, height: 8)
                    Circle()
                        .fill(Color.veryLightGray) // Из Color+Extensions.swift
                        .frame(width: 8, height: 8)
                    Circle()
                        .fill(Color.veryLightGray) // Из Color+Extensions.swift
                        .frame(width: 8, height: 8)
                }

                Button(action: onNext) {
                    Text("Начать")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(Color.textWhite) // Из Color+Extensions.swift (был .white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(Color.brandGreen) // Из Color+Extensions.swift
                        .cornerRadius(16)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 30)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.textWhite.ignoresSafeArea()) // Из Color+Extensions.swift (был Color.white)
        .navigationBarHidden(true)
    }
}

struct OnboardingWelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingWelcomeView(onSkip: {}, onNext: {})
    }
}
