import FirebaseFirestore
import Foundation

struct WarehouseModel: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var city: String
    var address: String
    var contacts: String
    var tariffs: [TariffModel] // Структурированные тарифы
    var isActive: Bool = true
    var settings: WarehouseSettings
    var createdAt: Date
    var updatedAt: Date
}

struct TariffModel: Codable {
    var serviceName: String // "Прием", "Хранение", "Отгрузка"
    var price: Double
    var unit: String // "за единицу", "за м²", "за день"
}

struct WarehouseSettings: Codable {
    var workingHours: String
    var maxCapacity: Int
    var autoAcceptOrders: Bool
    var notificationsEnabled: Bool
}
