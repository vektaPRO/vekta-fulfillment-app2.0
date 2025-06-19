// Файл: Color+Extensions.swift

import SwiftUI

extension Color {
    // MARK: - Основные фирменные цвета
    /// Основной зеленый цвет бренда VEKTA.
    static let brandGreen = Color(red: 52/255, green: 199/255, blue: 89/255) // Из OnboardingWelcomeView
    // Если нужен другой оттенок зеленого для LoginScreen (74/255, 189/255, 100/255),
    // реши, какой использовать глобально, или дай им разные имена.
    // Сейчас используется тот, что был в OnboardingWelcomeView.

    /// Синий цвет для элементов Kaspi.
    static let kaspiBlue = Color(red: 0/255, green: 110/255, blue: 237/255) // Из OnboardingWelcomeView

    // MARK: - Оттенки серого для UI элементов
    
    /// Очень светлый серый. Используется для фона полей ввода. Аналог Tailwind `gray-50`.
    static let backgroundGray = Color(UIColor.systemGray6)
    
    /// Светлый серый. Используется для рамок полей ввода, разделителей, неактивных точек индикатора. Аналог Tailwind `gray-200`.
    static let veryLightGray = Color(UIColor.systemGray5) // Используется в Onboarding и Login
    
    /// Серый для плейсхолдеров и второстепенного текста (например, "Или" в LoginScreenView). Аналог Tailwind `gray-500`.
    static let placeholderGray = Color(UIColor.systemGray2)
    
    /// Серый для основного неактивного/второстепенного текста (например, описание в Onboarding, лого "2.0" в LoginScreen).
    static let lightGrayText = Color.gray.opacity(0.8) // Из OnboardingWelcomeView

    // MARK: - Текстовые цвета (основные)
    
    /// Стандартный черный текст.
    static let textBlack = Color.black
    
    /// Стандартный белый текст.
    static let textWhite = Color.white
}
