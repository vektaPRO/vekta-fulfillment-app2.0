// MARK: - UserModel.swift
import FirebaseFirestore
import Foundation

struct UserModel: Identifiable, Codable {
    @DocumentID var id: String?
    var email: String
    var displayName: String
    var role: UserRole
    var warehouseId: String? // nil для SuperAdmin
    var uid: String // Firebase Auth UID для связи
    var isActive: Bool = true
    var createdAt: Date
    var updatedAt: Date
    
    // Добавляем инициализатор для совместимости
    init(id: String? = nil,
         email: String,
         displayName: String,
         role: UserRole,
         warehouseId: String? = nil,
         uid: String,
         isActive: Bool = true,
         createdAt: Date = Date(),
         updatedAt: Date = Date()) {
        self.id = id
        self.email = email
        self.displayName = displayName
        self.role = role
        self.warehouseId = warehouseId
        self.uid = uid
        self.isActive = isActive
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
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
