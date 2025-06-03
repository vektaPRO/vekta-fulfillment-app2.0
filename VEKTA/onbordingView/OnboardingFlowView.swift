// Файл: OnboardingFlowView.swift

import SwiftUI

struct OnboardingFlowView: View {
    @State private var currentStep: OnboardingStep = .welcome
    
    var onCompleteOrSkip: () -> Void // Это замыкание вызовет VEKTAApp для скрытия онбординга

    var body: some View {
        // Используем NavigationStack для возможности использования NavigationLink если понадобится в будущем,
        // но для простой смены View можно обойтись и без него, просто меняя currentStep.
        // NavigationView/NavigationStack важен если мы хотим стандартные push-анимации.
        // В данном случае, мы меняем все View, так что анимация будет зависеть от withAnimation.
        
        // Чтобы анимация смены экранов была плавной:
        Group { // Оборачиваем в Group для применения transition ко всему блоку switch
            switch currentStep {
            case .welcome:
                OnboardingWelcomeView(
                    onSkip: {
                        onCompleteOrSkip()
                    },
                    onNext: {
                        withAnimation {
                            currentStep = .sellers
                        }
                    }
                )
                .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
            case .sellers:
                OnboardingSellersView( // Убедись, что этот файл есть и он корректен
                    onSkip: {
                        onCompleteOrSkip()
                    },
                    onBack: {
                        withAnimation {
                            currentStep = .welcome
                        }
                    },
                    onNext: {
                        withAnimation {
                            currentStep = .control
                        }
                    }
                )
                .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
            case .control:
                OnboardingControlView( // Убедись, что этот файл есть и он корректен (и правильно назван)
                    onSkip: {
                        onCompleteOrSkip()
                    },
                    onBack: {
                        withAnimation {
                            currentStep = .sellers
                        }
                    },
                    onStartWorking: { // Эта кнопка должна вести к завершению онбординга
                        onCompleteOrSkip()
                    }
                )
                .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
            }
        }
        .animation(.default, value: currentStep) // Анимируем изменение currentStep
    }
}

struct OnboardingFlowView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingFlowView(onCompleteOrSkip: { print("Onboarding finished or skipped") })
    }
}
