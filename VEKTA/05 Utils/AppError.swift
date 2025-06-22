import Foundation

enum AppError: LocalizedError {
    case firebase(Error)
    case auth(Error)
    case decoding(Error)
    case custom(String)
    case unknown

    var errorDescription: String? {
        switch self {
        case .firebase(let error):
            return "Ошибка сервера: \(error.localizedDescription)"
        case .auth(let error):
            return "Ошибка авторизации: \(error.localizedDescription)"
        case .decoding(let error):
            return "Ошибка обработки данных: \(error.localizedDescription)"
        case .custom(let message):
            return message
        case .unknown:
            return "Неизвестная ошибка"
        }
    }
}
