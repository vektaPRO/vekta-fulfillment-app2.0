import FirebaseFirestore
import Foundation

struct ShipmentModel: Identifiable, Codable {
    @DocumentID var id: String?
    var type: ShipmentType
    var status: ShipmentStatus
    var products: [ShipmentProduct] // Детализированный список товаров
    var warehouseId: String
    var sellerId: String? // Для outgoing shipments
    var courierId: String? // Назначенный курьер
    
    // Kaspi интеграция
    var kaspiOrderId: String? // ID заказа в Kaspi
    var trackingNumber: String?
    
    // Финансы
    var totalAmount: Double?
    var commission: Double?
    var deliveryFee: Double?
    
    // Адрес и контакты (для доставки)
    var deliveryAddress: Address?
    var customerPhone: String?
    var customerName: String?
    
    // Временные метки
    var createdAt: Date
    var updatedAt: Date
    var scheduledAt: Date? // Запланированная дата
    var completedAt: Date? // Дата завершения
    
    // QR коды
    var qrCode: String? // QR код отгрузки
    var verificationCode: String? // Код подтверждения
}

enum ShipmentType: String, Codable {
    case incoming = "incoming"   // Приемка
    case outgoing = "outgoing"   // Отгрузка
    case return_item = "return"  // Возврат
    case transfer = "transfer"   // Перемещение между складами
}

enum ShipmentStatus: String, Codable {
    case created = "created"
    case processing = "processing"
    case ready = "ready"
    case in_delivery = "in_delivery"
    case delivered = "delivered"
    case cancelled = "cancelled"
    case returned = "returned"
    
    var displayName: String {
        switch self {
        case .created: return "Создан"
        case .processing: return "В обработке"
        case .ready: return "Готов к отгрузке"
        case .in_delivery: return "В доставке"
        case .delivered: return "Доставлен"
        case .cancelled: return "Отменен"
        case .returned: return "Возвращен"
        }
    }
}

struct ShipmentProduct: Codable {
    var productId: String
    var productName: String // Дублируем для удобства
    var quantity: Int
    var receivedQuantity: Int = 0 // Фактически принято
    var unitPrice: Double?
    var totalPrice: Double? {
        guard let unitPrice = unitPrice else { return nil }
        return unitPrice * Double(quantity)
    }
}

struct Address: Codable {
    var street: String
    var city: String
    var region: String?
    var postalCode: String?
    var country: String = "Kazakhstan"
    var coordinates: GeoPoint?
    
    var fullAddress: String {
        return [street, city, region, country].compactMap { $0 }.joined(separator: ", ")
    }
}
