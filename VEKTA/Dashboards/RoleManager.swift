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
    
    func fetchUserRole(for uid: String) {
        print("🔍 Начинаем поиск пользователя с UID: \(uid)")
        
        isLoadingUser = true
        errorMessage = nil
        
        db.collection("users")
            .whereField("uid", isEqualTo: uid)
            .getDocuments { [weak self] snapshot, error in
                DispatchQueue.main.async {
                    self?.isLoadingUser = false
                    
                    if let error = error {
                        print("❌ Ошибка Firestore: \(error.localizedDescription)")
                        self?.errorMessage = "Ошибка загрузки пользователя: \(error.localizedDescription)"
                        return
                    }
                    
                    guard let documents = snapshot?.documents else {
                        print("❌ Snapshot is nil")
                        self?.errorMessage = "Не удалось получить данные из базы"
                        return
                    }
                    
                    print("📄 Найдено документов: \(documents.count)")
                    
                    if documents.isEmpty {
                        print("⚠️ Пользователь не найден в коллекции users")
                        self?.errorMessage = "Пользователь не найден в системе. Обратитесь к администратору."
                        return
                    }
                    
                    do {
                        let userData = documents[0].data()
                        print("📋 Данные пользователя: \(userData)")
                        
                        let user = try Firestore.Decoder().decode(UserModel.self, from: userData)
                        self?.currentUser = user
                        print("✅ Пользователь успешно загружен: \(user.displayName) (\(user.role.displayName))")
                        
                    } catch {
                        print("❌ Ошибка декодирования: \(error)")
                        
                        // Если есть ошибка декодирования, попробуем создать пользователя вручную
                        if let userData = documents.first?.data() {
                            self?.handleDecodingError(userData: userData, uid: uid)
                        } else {
                            self?.errorMessage = "Ошибка обработки данных пользователя: \(error.localizedDescription)"
                        }
                    }
                }
            }
    }
    
    // Обработка ошибки декодирования с попыткой ручного создания
    private func handleDecodingError(userData: [String: Any], uid: String) {
        print("🔧 Попытка ручного создания пользователя из данных: \(userData)")
        
        guard let email = userData["email"] as? String,
              let displayName = userData["displayName"] as? String,
              let roleString = userData["role"] as? String,
              let role = UserRole(rawValue: roleString),
              let isActive = userData["isActive"] as? Bool else {
            
            print("❌ Не удалось извлечь обязательные поля из данных")
            self.errorMessage = "Неполные данные пользователя в базе"
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
        print("✅ Пользователь создан вручную: \(user.displayName) (\(user.role.displayName))")
    }
    
    func clearCurrentUser() {
        print("🧹 Очищаем данные пользователя")
        currentUser = nil
        errorMessage = nil
        isLoadingUser = false
    }
}
