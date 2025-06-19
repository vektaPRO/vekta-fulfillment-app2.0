// MARK: - UserModel.swift (улучшенная версия)
import FirebaseFirestore
import Foundation

struct UserModel: Identifiable, Codable {
    @DocumentID var id: String?
    var email: String
    var displayName: String // Добавил для отображения в UI
    var role: UserRole
    var warehouseId: String? // nil для SuperAdmin
    var uid: String // Firebase Auth UID для связи
    var isActive: Bool = true // Для деактивации пользователей
    var createdAt: Date
    var updatedAt: Date
}

enum UserRole: String, Codable, CaseIterable {
    case superadmin = "superadmin"
    case warehouseAdmin = "warehouseAdmin"
    case seller = "seller"
    case courier = "courier"
    
    var displayName: String {
        switch self {
        case .superadmin: return "Супер Администратор"
        case .warehouseAdmin: return "Администратор Склада"
        case .seller: return "Селлер"
        case .courier: return "Курьер"
        }
    }
}
