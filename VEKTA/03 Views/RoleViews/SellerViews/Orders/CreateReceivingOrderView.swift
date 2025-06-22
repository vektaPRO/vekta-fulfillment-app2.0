// MARK: - CreateReceivingOrderView.swift
// Экран создания заказа на приемку для селлера

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct CreateReceivingOrderView: View {
    @State private var selectedProducts: [ReceivingProduct] = []
    @State private var showAddProduct = false
    @State private var selectedWarehouse: String = ""
    @State private var warehouses: [WarehouseModel] = []
    @State private var isLoading = false
    @State private var showQRCodes = false
    @State private var qrProducts: [ReceivingProduct] = []
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Выбор склада
                VStack(alignment: .leading, spacing: 8) {
                    Text("Выберите склад")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    Picker("Склад", selection: $selectedWarehouse) {
                        Text("Выберите склад").tag("")
                        ForEach(warehouses) { warehouse in
                            Text(warehouse.name).tag(warehouse.id ?? "")
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
                .padding(.top)
                
                // Список товаров
                if selectedProducts.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "cube.box")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("Добавьте товары для приемки")
                            .font(.headline)
                            .foregroundColor(.gray)
                        
                        Button(action: { showAddProduct = true }) {
                            Label("Добавить товар", systemImage: "plus.circle.fill")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.brandGreen)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach($selectedProducts) { $product in
                            ProductReceivingRow(product: $product)
                        }
                        .onDelete(perform: deleteProduct)
                        
                        Button(action: { showAddProduct = true }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("Добавить еще товар")
                            }
                            .foregroundColor(.brandGreen)
                        }
                        .padding(.vertical, 8)
                    }
                }
                
                // Кнопка создания заказа
                if !selectedProducts.isEmpty && !selectedWarehouse.isEmpty {
                    VStack(spacing: 16) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Итого товаров:")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Text("\(totalQuantity) шт.")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing) {
                                Text("Позиций:")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Text("\(selectedProducts.count)")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                            }
                        }
                        .padding(.horizontal)
                        
                        Button(action: createReceivingOrder) {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Создать заказ на приемку")
                                    .font(.system(size: 18, weight: .medium))
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.brandGreen)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .disabled(isLoading)
                        .padding(.horizontal)
                    }
                    .padding(.vertical)
                    .background(Color(.systemBackground))
                }
            }
            .navigationTitle("Новая приемка")
            .navigationBarItems(
                leading: Button("Отмена") { presentationMode.wrappedValue.dismiss() }
            )
            .sheet(isPresented: $showAddProduct) {
                AddProductToReceivingView { product in
                    selectedProducts.append(product)
                }
            }
            .sheet(isPresented: $showQRCodes) {
                QRCodesView(products: qrProducts)
            }
        }
        .onAppear {
            loadWarehouses()
        }
    }
    
    private var totalQuantity: Int {
        selectedProducts.reduce(0) { $0 + $1.quantity }
    }
    
    private func deleteProduct(at offsets: IndexSet) {
        selectedProducts.remove(atOffsets: offsets)
    }
    
    private func loadWarehouses() {
        let db = Firestore.firestore()
        db.collection("warehouses")
            .whereField("isActive", isEqualTo: true)
            .getDocuments { snapshot, error in
                if let documents = snapshot?.documents {
                    self.warehouses = documents.compactMap { doc in
                        try? doc.data(as: WarehouseModel.self)
                    }
                }
            }
    }
    
    private func createReceivingOrder() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        isLoading = true
        
        // Создаем документ приемки
        let receivingOrder = ReceivingOrder(
            sellerId: userId,
            warehouseId: selectedWarehouse,
            products: selectedProducts,
            status: .created,
            createdAt: Date()
        )
        
        let db = Firestore.firestore()
        
        do {
            try db.collection("receivingOrders").addDocument(from: receivingOrder)

            qrProducts = selectedProducts
            showQRCodes = true
            isLoading = false

        } catch {
            AlertManager.shared.show(error: AppError.firebase(error))
            isLoading = false
        }
    }
}

// MARK: - Supporting Views

struct ProductReceivingRow: View {
    @Binding var product: ReceivingProduct
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(product.name)
                    .font(.headline)
                Text("Артикул: \(product.sku)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            HStack(spacing: 16) {
                Button(action: { if product.quantity > 1 { product.quantity -= 1 } }) {
                    Image(systemName: "minus.circle.fill")
                        .foregroundColor(.brandGreen)
                }
                
                Text("\(product.quantity)")
                    .font(.headline)
                    .frame(minWidth: 30)
                
                Button(action: { product.quantity += 1 }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.brandGreen)
                }
            }
        }
        .padding(.vertical, 8)
    }
}

struct AddProductToReceivingView: View {
    @State private var productName = ""
    @State private var productSKU = ""
    @State private var quantity = 1
    @Environment(\.presentationMode) var presentationMode
    
    let onAdd: (ReceivingProduct) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Информация о товаре")) {
                    TextField("Название товара", text: $productName)
                    TextField("Артикул (SKU)", text: $productSKU)
                }
                
                Section(header: Text("Количество")) {
                    Stepper(value: $quantity, in: 1...9999) {
                        HStack {
                            Text("Количество:")
                            Spacer()
                            Text("\(quantity) шт.")
                                .fontWeight(.semibold)
                        }
                    }
                }
            }
            .navigationTitle("Добавить товар")
            .navigationBarItems(
                leading: Button("Отмена") { presentationMode.wrappedValue.dismiss() },
                trailing: Button("Добавить") {
                    let product = ReceivingProduct(
                        name: productName,
                        sku: productSKU,
                        quantity: quantity
                    )
                    onAdd(product)
                    presentationMode.wrappedValue.dismiss()
                }
                .disabled(productName.isEmpty || productSKU.isEmpty)
            )
        }
    }
}

struct QRCodesView: View {
    let products: [ReceivingProduct]
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Text("QR-коды для товаров")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.top)
                    
                    Text("Распечатайте и наклейте на товары")
                        .foregroundColor(.gray)
                    
                    ForEach(products) { product in
                        VStack(spacing: 12) {
                            QRCodeView(data: QRService.shared.dataForProduct(product))
                                .frame(width: 150, height: 150)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(12)
                                .shadow(radius: 4)

                            VStack(spacing: 4) {
                                Text(product.name)
                                    .font(.headline)
                                Text("SKU: \(product.sku)")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Text("Кол-во: \(product.quantity) шт.")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                }
                .padding()
            }
            .navigationBarItems(
                trailing: Button("Готово") { presentationMode.wrappedValue.dismiss() }
            )
        }
    }
}

// MARK: - Models

struct ReceivingOrder: Codable {
    var sellerId: String
    var warehouseId: String
    var products: [ReceivingProduct]
    var status: ReceivingStatus
    var createdAt: Date
    var receivedAt: Date?
    var receivedBy: String?
}

struct ReceivingProduct: Codable, Identifiable {
    var id = UUID().uuidString
    var name: String
    var sku: String
    var quantity: Int
    var receivedQuantity: Int = 0
}

enum ReceivingStatus: String, Codable {
    case created = "created"
    case inTransit = "in_transit"
    case receiving = "receiving"
    case completed = "completed"
    case cancelled = "cancelled"
}

