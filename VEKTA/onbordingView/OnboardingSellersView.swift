import SwiftUI

struct OnboardingSellersView: View {
    var onSkip: () -> Void
    var onBack: () -> Void
    var onNext: () -> Void

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
                // Визуальный элемент (Иллюстрация "До/После")
                // ЗАГЛУШКА: Заменить на Image("onboardingSellersIllustration")
                Image(systemName: "arrow.left.arrow.right.square.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 150) // Примерный размер для w-80 h-64
                    .foregroundColor(Color.brandGreen)
                    .padding(.bottom, 20)
                
                Text("Больше Никаких Хлопот\nс Заказами Kaspi")
                    .font(.system(size: 30, weight: .light))
                    .foregroundColor(Color.black)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)

                Text("VEKTA 2.0 автоматически синхронизирует ваши заказы, управляет остатками и сокращает время на рутину.")
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
                        .fill(Color.brandGreen)
                        .frame(width: 8, height: 8)
                    Circle()
                        .fill(Color.veryLightGray)
                        .frame(width: 8, height: 8)
                }

                // Кнопки навигации
                HStack(spacing: 16) {
                    Button(action: {
                        onBack()
                    }) {
                        Text("Назад")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(Color.gray) // text-gray-600
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 15)
                            .background(Color.veryLightGray) // bg-gray-100
                            .cornerRadius(16)
                    }

                    Button(action: {
                        onNext()
                    }) {
                        Text("Далее")
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
struct OnboardingSellersView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingSellersView(onSkip: {}, onBack: {}, onNext: {})
    }
}
