// MARK: - RoleManager.swift
import FirebaseFirestore
import FirebaseAuth
import Foundation
import Combine

class RoleManager: ObservableObject {
    @Published var currentUser: UserModel?
    @Published var isLoadingUser = false
    @Published var errorMessage: String?
    
    private let db = Firestore.firestore()
    
    func fetchUserRole(for uid: String, retries: Int = 3) {
        isLoadingUser = true
        errorMessage = nil

        db.collection("users")
            .whereField("uid", isEqualTo: uid)
            .getDocuments { [weak self] snapshot, error in
                DispatchQueue.main.async {
                    self?.isLoadingUser = false

                    if let error = error {
                        if retries > 1 {
                            self?.fetchUserRole(for: uid, retries: retries - 1)
                        } else {
                            self?.errorMessage = error.localizedDescription
                            AlertManager.shared.show(error: AppError.firebase(error))
                        }
                        return
                    }

                    guard let documents = snapshot?.documents else {
                        self?.errorMessage = "Не удалось получить данные из базы"
                        AlertManager.shared.show(error: AppError.custom("Не удалось получить данные из базы"))
                        return
                    }

                    if documents.isEmpty {
                        self?.errorMessage = "Пользователь не найден в системе. Обратитесь к администратору."
                        AlertManager.shared.show(error: AppError.custom("Пользователь не найден"))
                        return
                    }

                    do {
                        let userData = documents[0].data()
                        let user = try Firestore.Decoder().decode(UserModel.self, from: userData)
                        self?.currentUser = user
                    } catch {
                        if let userData = documents.first?.data() {
                            self?.handleDecodingError(userData: userData, uid: uid)
                        } else {
                            self?.errorMessage = error.localizedDescription
                            AlertManager.shared.show(error: AppError.decoding(error))
                        }
                    }
                }
            }
    }
    
    // Обработка ошибки декодирования с попыткой ручного создания
    private func handleDecodingError(userData: [String: Any], uid: String) {
        
        guard let email = userData["email"] as? String,
              let displayName = userData["displayName"] as? String,
              let roleString = userData["role"] as? String,
              let role = UserRole(rawValue: roleString),
              let isActive = userData["isActive"] as? Bool else {
            
            self.errorMessage = "Неполные данные пользователя в базе"
            AlertManager.shared.show(error: AppError.custom("Неполные данные пользователя"))
            return
        }
        
        // Создаем пользователя вручную
        let user = UserModel(
            id: nil,
            email: email,
            displayName: displayName,
            role: role,
            warehouseId: userData["warehouseId"] as? String,
            uid: uid,
            isActive: isActive,
            createdAt: (userData["createdAt"] as? Timestamp)?.dateValue() ?? Date(),
            updatedAt: (userData["updatedAt"] as? Timestamp)?.dateValue() ?? Date()
        )
        
        self.currentUser = user
    }
    
    func clearCurrentUser() {
        currentUser = nil
        errorMessage = nil
        isLoadingUser = false
    }
}
