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
        isLoadingUser = true
        errorMessage = nil
        
        db.collection("users")
            .whereField("uid", isEqualTo: uid)
            .getDocuments { [weak self] snapshot, error in
                DispatchQueue.main.async {
                    self?.isLoadingUser = false
                    
                    if let error = error {
                        self?.errorMessage = "Ошибка загрузки пользователя: \(error.localizedDescription)"
                        return
                    }
                    
                    guard let documents = snapshot?.documents, !documents.isEmpty else {
                        self?.errorMessage = "Пользователь не найден в системе"
                        return
                    }
                    
                    do {
                        let userData = documents[0].data()
                        self?.currentUser = try Firestore.Decoder().decode(UserModel.self, from: userData)
                    } catch {
                        self?.errorMessage = "Ошибка декодирования данных пользователя"
                    }
                }
            }
    }
    
    func clearCurrentUser() {
        currentUser = nil
        errorMessage = nil
    }
}
