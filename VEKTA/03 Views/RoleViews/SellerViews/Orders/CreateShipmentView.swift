import SwiftUI
import FirebaseFirestore
import FirebaseAuth

// MARK: - Create Shipment View
struct CreateShipmentView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel = CreateShipmentViewModel()
    @State private var showingProductPicker = false
    @State private var showingQRCode = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Форма
                Form {
                    // Выбор склада
                    Section("Склад назначения") {
                        Picker("Выберите склад", selection: $viewModel.selectedWarehouse) {
                            Text("Выберите склад").tag(nil as WarehouseModel?)
                            ForEach(viewModel.warehouses) { warehouse in
                                Text(warehouse.name).tag(warehouse as WarehouseModel?)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                    
                    // Список товаров
                    Section("Товары для приемки") {
                        if viewModel.selectedProducts.isEmpty {
                            Button(action: { showingProductPicker = true }) {
                                HStack {
                                    Image(systemName: "plus.circle.fill")
                                        .foregroundColor(.brandGreen)
                                    Text("Добавить товары")
                                        .foregroundColor(.brandGreen)
                                }
                            }
                        } else {
                            ForEach(viewModel.selectedProducts) { item in
                                ShipmentProductRow(item: item) { newQuantity in
                                    viewModel.updateQuantity(for: item.id, quantity: newQuantity)
                                } onDelete: {
                                    viewModel.removeProduct(item.id)
                                }
                            }
                            
                            Button(action: { showingProductPicker = true }) {
                                HStack {
                                    Image(systemName: "plus.circle")
                                        .foregroundColor(.brandGreen)
                                    Text("Добавить еще товар")
                                        .font(.subheadline)
                                        .foregroundColor(.brandGreen)
                                }
                            }
                        }
                    }
                    
                    // Итоговая информация
                    if !viewModel.selectedProducts.isEmpty {
                        Section("Итого") {
                            HStack {
                                Text("Товаров")
                                Spacer()
                                Text("\(viewModel.selectedProducts.count)")
                                    .fontWeight(.medium)
                            }
                            
                            HStack {
                                Text("Единиц")
                                Spacer()
                                Text("\(viewModel.totalUnits)")
                                    .fontWeight(.medium)
                            }
                            
                            if viewModel.totalCost > 0 {
                                HStack {
                                    Text("Себестоимость")
                                    Spacer()
                                    Text("\(Int(viewModel.totalCost)) ₸")
                                        .fontWeight(.medium)
                                }
                            }
                        }
                    }
                }
                
                // Кнопка создания
                if viewModel.canCreateShipment {
                    VStack {
                        Button(action: {
                            viewModel.createShipment { success in
                                if success {
                                    showingQRCode = true
                                }
                            }
                        }) {
                            if viewModel.isCreating {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                            } else {
                                Text("Создать приемку")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                            }
                        }
                        .background(Color.brandGreen)
                        .cornerRadius(12)
                        .disabled(viewModel.isCreating)
                        .padding()
                    }
                    .background(Color(.systemBackground))
                }
            }
            .navigationTitle("Новая приемка")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingProductPicker) {
                ProductPickerView(
                    selectedProducts: $viewModel.selectedProducts,
                    onSelect: { products in
                        viewModel.addProducts(products)
                    }
                )
            }
            .sheet(isPresented: $showingQRCode) {
                if let shipment = viewModel.createdShipment {
                    ShipmentQRCodeView(shipment: shipment) {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .alert("Ошибка", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") {
                    viewModel.errorMessage = nil
                }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
        .onAppear {
            viewModel.loadWarehouses()
        }
    }
}

// MARK: - Shipment Product Row
struct ShipmentProductRow: View {
    let item: ShipmentProductItem
    let onQuantityChange: (Int) -> Void
    let onDelete: () -> Void
    
    @State private var quantity: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.product.name)
                        .font(.headline)
                    
                    if let sku = item.product.sku {
                        Text("Артикул: \(sku)")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
                
                Button(action: onDelete) {
                    Image(systemName: "minus.circle.fill")
                        .foregroundColor(.red)
                }
            }
            
            HStack {
                Text("Количество:")
                    .font(.subheadline)
                
                TextField("0", text: $quantity)
                    .keyboardType(.numberPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 80)
                    .onChange(of: quantity) { newValue in
                        if let qty = Int(newValue) {
                            onQuantityChange(qty)
                        }
                    }
                
                Text("шт.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Spacer()
            }
        }
        .padding(.vertical, 4)
        .onAppear {
            quantity = "\(item.quantity)"
        }
    }
}

// MARK: - Product Picker View
struct ProductPickerView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var selectedProducts: [ShipmentProductItem]
    @StateObject private var viewModel = ProductPickerViewModel()
    @State private var searchText = ""
    
    let onSelect: ([ProductModel]) -> Void
    
    var body: some View {
        NavigationView {
            VStack {
                SearchBar(text: $searchText)
                    .padding(.horizontal)
                
                if viewModel.isLoading {
                    ProgressView("Загрузка товаров...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(filteredProducts) { product in
                            ProductPickerRow(
                                product: product,
                                isSelected: viewModel.selectedProductIds.contains(product.id ?? "")
                            ) {
                                viewModel.toggleProduct(product)
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("Выберите товары")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Добавить (\(viewModel.selectedProducts.count))") {
                        onSelect(viewModel.selectedProducts)
                        presentationMode.wrappedValue.dismiss()
                    }
                    .disabled(viewModel.selectedProducts.isEmpty)
                }
            }
        }
        .onAppear {
            viewModel.loadProducts()
            // Предустановим выбранные товары
            viewModel.selectedProductIds = Set(selectedProducts.compactMap { $0.product.id })
        }
    }
    
    var filteredProducts: [ProductModel] {
        if searchText.isEmpty {
            return viewModel.products
        } else {
            return viewModel.products.filter { product in
                product.name.localizedCaseInsensitiveContains(searchText) ||
                (product.sku?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
    }
}

// MARK: - Product Picker Row
struct ProductPickerRow: View {
    let product: ProductModel
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(product.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    HStack {
                        if let sku = product.sku {
                            Text("Артикул: \(sku)")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        Text("Остаток: \(product.currentStock)")
                            .font(.caption)
                            .foregroundColor(product.currentStock > 0 ? .green : .red)
                    }
                }
                
                Spacer()
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .brandGreen : .gray)
                    .font(.title2)
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Shipment QR Code View
struct ShipmentQRCodeView: View {
    let shipment: ShipmentModel
    let onDone: () -> Void
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // QR код приемки
                    VStack(spacing: 16) {
                        Text("QR-код приемки")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        QRCodeView(data: QRService.shared.dataForShipment(shipment))
                            .frame(width: 200, height: 200)
                        
                        Text("ID: \(shipment.id ?? "")")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    // Информация о приемке
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Статус:")
                                .fontWeight(.medium)
                            Spacer()
                            Text(shipment.status.displayName)
                                .foregroundColor(.brandGreen)
                        }
                        
                        HStack {
                            Text("Товаров:")
                                .fontWeight(.medium)
                            Spacer()
                            Text("\(shipment.products.count)")
                        }
                        
                        HStack {
                            Text("Всего единиц:")
                                .fontWeight(.medium)
                            Spacer()
                            Text("\(shipment.products.reduce(0) { $0 + $1.quantity })")
                        }
                        
                        if let warehouseId = shipment.warehouseId {
                            HStack {
                                Text("Склад:")
                                    .fontWeight(.medium)
                                Spacer()
                                Text(warehouseId) // TODO: Загрузить название склада
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Список товаров
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Товары в приемке")
                            .font(.headline)
                        
                        ForEach(shipment.products, id: \.productId) { product in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(product.productName)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    Text("Количество: \(product.quantity)")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                            }
                            .padding(.vertical, 8)
                            Divider()
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Инструкция
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Сохраните или распечатайте QR-код", systemImage: "info.circle")
                            .font(.caption)
                            .foregroundColor(.blue)
                        
                        Text("Покажите этот QR-код на складе для быстрой приемки товаров")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding()
                }
                .padding()
            }
            .navigationTitle("Приемка создана")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Готово") {
                        onDone()
                    }
                }
            }
        }
    }
}

// MARK: - View Models
class CreateShipmentViewModel: ObservableObject {
    @Published var warehouses: [WarehouseModel] = []
    @Published var selectedWarehouse: WarehouseModel?
    @Published var selectedProducts: [ShipmentProductItem] = []
    @Published var isCreating = false
    @Published var createdShipment: ShipmentModel?
    @Published var errorMessage: String?
    
    private let db = Firestore.firestore()
    
    var canCreateShipment: Bool {
        selectedWarehouse != nil && !selectedProducts.isEmpty && selectedProducts.allSatisfy { $0.quantity > 0 }
    }
    
    var totalUnits: Int {
        selectedProducts.reduce(0) { $0 + $1.quantity }
    }
    
    var totalCost: Double {
        selectedProducts.reduce(0) { total, item in
            total + (item.product.costPrice ?? 0) * Double(item.quantity)
        }
    }
    
    func loadWarehouses() {
        db.collection("warehouses")
            .whereField("isActive", isEqualTo: true)
            .getDocuments { [weak self] snapshot, error in
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    return
                }
                
                self?.warehouses = snapshot?.documents.compactMap { document in
                    try? document.data(as: WarehouseModel.self)
                } ?? []
            }
    }
    
    func addProducts(_ products: [ProductModel]) {
        for product in products {
            if !selectedProducts.contains(where: { $0.product.id == product.id }) {
                selectedProducts.append(ShipmentProductItem(product: product, quantity: 1))
            }
        }
    }
    
    func updateQuantity(for itemId: String, quantity: Int) {
        if let index = selectedProducts.firstIndex(where: { $0.id == itemId }) {
            selectedProducts[index].quantity = quantity
        }
    }
    
    func removeProduct(_ itemId: String) {
        selectedProducts.removeAll { $0.id == itemId }
    }
    
    func createShipment(completion: @escaping (Bool) -> Void) {
        guard let warehouse = selectedWarehouse,
              let sellerId = Auth.auth().currentUser?.uid else {
            errorMessage = "Не выбран склад или пользователь не авторизован"
            completion(false)
            return
        }
        
        isCreating = true
        
        // Создаем модель приемки
        let shipmentProducts = selectedProducts.map { item in
            ShipmentProduct(
                productId: item.product.id ?? "",
                productName: item.product.name,
                quantity: item.quantity,
                unitPrice: item.product.costPrice
            )
        }
        
        let shipmentId = UUID().uuidString
        let qrCode = "VEKTA:SHIPMENT:\(shipmentId):\(sellerId)"
        
        let shipment = ShipmentModel(
            id: shipmentId,
            type: .incoming,
            status: .created,
            products: shipmentProducts,
            warehouseId: warehouse.id ?? "",
            sellerId: sellerId,
            totalAmount: totalCost,
            createdAt: Date(),
            updatedAt: Date(),
            qrCode: qrCode,
            verificationCode: String(format: "%06d", Int.random(in: 0...999999))
        )
        
        // Сохраняем в Firestore
        do {
            try db.collection("shipments").document(shipmentId).setData(from: shipment) { [weak self] error in
                DispatchQueue.main.async {
                    self?.isCreating = false
                    
                    if let error = error {
                        self?.errorMessage = error.localizedDescription
                        completion(false)
                    } else {
                        self?.createdShipment = shipment
                        completion(true)
                    }
                }
            }
        } catch {
            isCreating = false
            errorMessage = error.localizedDescription
            completion(false)
        }
    }
}

// MARK: - Product Picker View Model
class ProductPickerViewModel: ObservableObject {
    @Published var products: [ProductModel] = []
    @Published var selectedProducts: [ProductModel] = []
    @Published var selectedProductIds = Set<String>()
    @Published var isLoading = false
    
    private let db = Firestore.firestore()
    
    func loadProducts() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        isLoading = true
        
        db.collection("products")
            .whereField("sellerId", isEqualTo: uid)
            .whereField("isActive", isEqualTo: true)
            .getDocuments { [weak self] snapshot, error in
                self?.isLoading = false
                
                if let error = error {
                    print("Error loading products: \(error)")
                    return
                }
                
                self?.products = snapshot?.documents.compactMap { document in
                    try? document.data(as: ProductModel.self)
                } ?? []
            }
    }
    
    func toggleProduct(_ product: ProductModel) {
        guard let productId = product.id else { return }
        
        if selectedProductIds.contains(productId) {
            selectedProductIds.remove(productId)
            selectedProducts.removeAll { $0.id == productId }
        } else {
            selectedProductIds.insert(productId)
            selectedProducts.append(product)
        }
    }
}

// MARK: - Shipment Product Item
struct ShipmentProductItem: Identifiable {
    let id = UUID().uuidString
    let product: ProductModel
    var quantity: Int
}
