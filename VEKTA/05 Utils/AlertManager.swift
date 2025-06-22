import UIKit

final class AlertManager {
    static let shared = AlertManager()
    private init() {}

    func show(error: Error) {
        let message: String
        if let localizedError = error as? LocalizedError,
           let description = localizedError.errorDescription {
            message = description
        } else {
            message = error.localizedDescription
        }

        DispatchQueue.main.async {
            guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = scene.windows.first(where: { $0.isKeyWindow }),
                  let root = window.rootViewController else { return }

            let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            root.present(alert, animated: true)
        }
    }
}
