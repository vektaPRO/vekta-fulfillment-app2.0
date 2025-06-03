import SwiftUI

struct OnboardingControlView: View {
    var onSkip: () -> Void // Ведет на логин
    var onBack: () -> Void // Ведет на OnboardingSellers
    var onStartWorking: () -> Void // Ведет на логин

    var body: some View {
        VStack {
            // 1. Кнопка "Пропустить"
            HStack {
                Spacer()
                Button("Пропустить") {
                    onSkip()
                }
                .foregroundColor(Color.gray)
                .font(.system(size: 14, weight: .medium))
            }
            .padding(.top)
            .padding(.horizontal)

            Spacer()

            // 2. Основной контент
            VStack(spacing: 24) {
                // Визуальный элемент (Иллюстрация "Цепочка поставок")
                // ЗАГЛУШКА: Заменить на Image("onboardingControlIllustration")
                Image(systemName: "link.circle.fill") // Пример
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 150) // Примерный размер для w-80 h-64
                    .foregroundColor(Color.brandGreen)
                    .padding(.bottom, 20)

                Text("Контроль и Прозрачность\nна Каждом Этапе")
                    .font(.system(size: 30, weight: .light))
                    .foregroundColor(Color.black)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)

                Text("От приёмки товаров по QR до быстрой отгрузки и возвратов — полный контроль для каждого участника процесса.")
                    .font(.system(size: 17, weight: .regular))
                    .foregroundColor(Color.lightGrayText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
            }
            .padding(.horizontal)

            Spacer()

            // 3. Нижняя секция
            VStack(spacing: 20) {
                // Индикатор прогресса
                HStack(spacing: 8) {
                    Circle()
                        .fill(Color.veryLightGray)
                        .frame(width: 8, height: 8)
                    Circle()
                        .fill(Color.veryLightGray)
                        .frame(width: 8, height: 8)
                    Circle()
                        .fill(Color.brandGreen)
                        .frame(width: 8, height: 8)
                }

                // Кнопки навигации
                HStack(spacing: 16) {
                    Button(action: {
                        onBack()
                    }) {
                        Text("Назад")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(Color.gray)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 15)
                            .background(Color.veryLightGray)
                            .cornerRadius(16)
                    }

                    Button(action: {
                        onStartWorking()
                    }) {
                        Text("Начать работу")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 15)
                            .background(Color.brandGreen)
                            .cornerRadius(16)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 30)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white.ignoresSafeArea())
        .navigationBarHidden(true)
    }
}

// Для превью
struct OnboardingControlView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingControlView(onSkip: {}, onBack: {}, onStartWorking: {})
    }
}
