import FirebaseFirestore
import Foundation

struct ProductModel: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var sku: String? // Артикул продавца
    var barcode: String? // Штрихкод
    var category: String?
    var description: String?
    var sellerId: String // Привязка к продавцу
    var warehouseId: String
    
    // Остатки и учет
    var currentStock: Int = 0
    var reservedStock: Int = 0 // Зарезервированные для заказов
    var minStockLevel: Int = 0 // Минимальный остаток для уведомлений
    
    // Финансы
    var costPrice: Double? // Себестоимость
    var dimensions: ProductDimensions?
    var weight: Double? // в граммах
    
    var isActive: Bool = true
    var createdAt: Date
    var updatedAt: Date
}

struct ProductDimensions: Codable {
    var length: Double // см
    var width: Double  // см
    var height: Double // см
    
    var volume: Double {
        return length * width * height / 1000000 // в м³
    }
}
