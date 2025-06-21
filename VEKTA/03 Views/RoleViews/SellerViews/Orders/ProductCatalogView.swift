import SwiftUI
import FirebaseFirestore
import FirebaseAuth

// MARK: - Product Catalog View
struct ProductCatalogView: View {
    @StateObject private var viewModel = ProductCatalogViewModel()
    @State private var showingAddProduct = false
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            VStack {
                // Поиск
                SearchBar(text: $searchText)
                    .padding(.horizontal)
                
                if viewModel.isLoading {
                    ProgressView("Загрузка товаров...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.products.isEmpty {
                    EmptyStateView()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(filteredProducts) { product in
                                ProductCard(product: product)
                                    .onTapGesture {
                                        // TODO: Открыть детали товара
                                    }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Мои товары")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddProduct = true }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.brandGreen)
                    }
                }
            }
            .sheet(isPresented: $showingAddProduct) {
                AddProductView { newProduct in
                    viewModel.addProduct(newProduct)
                }
            }
        }
        .onAppear {
            viewModel.loadProducts()
        }
    }
    
    var filteredProducts: [ProductModel] {
        if searchText.isEmpty {
            return viewModel.products
        } else {
            return viewModel.products.filter { product in
                product.name.localizedCaseInsensitiveContains(searchText) ||
                (product.sku?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                (product.barcode?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
    }
}

// MARK: - Search Bar
struct SearchBar: UIViewRepresentable {
    @Binding var text: String
    
    func makeUIView(context: Context) -> UISearchBar {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Поиск по названию, артикулу или штрихкоду"
        searchBar.searchBarStyle = .minimal
        searchBar.delegate = context.coordinator
        return searchBar
    }
    
    func updateUIView(_ uiView: UISearchBar, context: Context) {
        uiView.text = text
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UISearchBarDelegate {
        let parent: SearchBar
        
        init(_ parent: SearchBar) {
            self.parent = parent
        }
        
        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            parent.text = searchText
        }
    }
}

// MARK: - Empty State
struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "cube.box")
                .font(.system(size: 80))
                .foregroundColor(.gray.opacity(0.3))
            
            Text("У вас пока нет товаров")
                .font(.title2)
                .fontWeight(.medium)
            
            Text("Добавьте первый товар, чтобы начать работу")
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

// MARK: - Product Card
struct ProductCard: View {
    let product: ProductModel
    
    var body: some View {
        HStack(spacing: 16) {
            // QR код товара
            QRCodeView(data: product.qrData)
                .frame(width: 60, height: 60)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(product.name)
                    .font(.headline)
                    .lineLimit(1)
                
                HStack {
                    if let sku = product.sku {
                        Label(sku, systemImage: "number")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    if let barcode = product.barcode {
                        Label(barcode, systemImage: "barcode")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                
                HStack {
                    Text("Остаток: \(product.currentStock)")
                        .font(.subheadline)
                        .foregroundColor(product.currentStock > 0 ? .green : .red)
                    
                    Spacer()
                    
                    if let costPrice = product.costPrice {
                        Text("\(Int(costPrice)) ₸")
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray.opacity(0.5))
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Add Product View
struct AddProductView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel = AddProductViewModel()
    
    let onSave: (ProductModel) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section("Основная информация") {
                    TextField("Название товара", text: $viewModel.name)
                    TextField("Артикул (SKU)", text: $viewModel.sku)
                        .autocapitalization(.none)
                    TextField("Штрихкод", text: $viewModel.barcode)
                        .keyboardType(.numberPad)
                }
                
                Section("Категория и описание") {
                    TextField("Категория", text: $viewModel.category)
                    TextEditor(text: $viewModel.description)
                        .frame(height: 100)
                }
                
                Section("Финансы") {
                    HStack {
                        Text("Себестоимость")
                        Spacer()
                        TextField("0", text: $viewModel.costPrice)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                        Text("₸")
                    }
                }
                
                Section("Габариты (опционально)") {
                    HStack {
                        Text("Длина (см)")
                        Spacer()
                        TextField("0", text: $viewModel.length)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text("Ширина (см)")
                        Spacer()
                        TextField("0", text: $viewModel.width)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text("Высота (см)")
                        Spacer()
                        TextField("0", text: $viewModel.height)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text("Вес (г)")
                        Spacer()
                        TextField("0", text: $viewModel.weight)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                }
            }
            .navigationTitle("Новый товар")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") {
                        if let product = viewModel.createProduct() {
                            onSave(product)
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                    .disabled(!viewModel.isValid)
                }
            }
        }
    }
}

// MARK: - QR Code View
struct QRCodeView: View {
    let data: String
    
    var body: some View {
        // Заглушка для QR кода
        ZStack {
            Rectangle()
                .fill(Color.gray.opacity(0.1))
            
            Image(systemName: "qrcode")
                .font(.title)
                .foregroundColor(.gray.opacity(0.5))
        }
    }
}

// MARK: - View Models
class ProductCatalogViewModel: ObservableObject {
    @Published var products: [ProductModel] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let db = Firestore.firestore()
    
    func loadProducts() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        isLoading = true
        
        db.collection("products")
            .whereField("sellerId", isEqualTo: uid)
            .whereField("isActive", isEqualTo: true)
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                self?.isLoading = false
                
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    return
                }
                
                self?.products = snapshot?.documents.compactMap { document in
                    try? document.data(as: ProductModel.self)
                } ?? []
            }
    }
    
    func addProduct(_ product: ProductModel) {
        do {
            _ = try db.collection("products").addDocument(from: product)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

class AddProductViewModel: ObservableObject {
    @Published var name = ""
    @Published var sku = ""
    @Published var barcode = ""
    @Published var category = ""
    @Published var description = ""
    @Published var costPrice = ""
    @Published var length = ""
    @Published var width = ""
    @Published var height = ""
    @Published var weight = ""
    
    var isValid: Bool {
        !name.isEmpty && !sku.isEmpty
    }
    
    func createProduct() -> ProductModel? {
        guard isValid,
              let uid = Auth.auth().currentUser?.uid else { return nil }
        
        var dimensions: ProductDimensions?
        if let l = Double(length), let w = Double(width), let h = Double(height), l > 0, w > 0, h > 0 {
            dimensions = ProductDimensions(length: l, width: w, height: h)
        }
        
        return ProductModel(
            name: name,
            sku: sku.isEmpty ? nil : sku,
            barcode: barcode.isEmpty ? nil : barcode,
            category: category.isEmpty ? nil : category,
            description: description.isEmpty ? nil : description,
            sellerId: uid,
            warehouseId: "", // Будет установлен при приемке
            costPrice: Double(costPrice),
            dimensions: dimensions,
            weight: Double(weight),
            createdAt: Date(),
            updatedAt: Date()
        )
    }
}

// MARK: - Extensions
extension ProductModel {
    var qrData: String {
        // Формат QR кода: VEKTA:PRODUCT:{SKU}:{SELLER_ID}
        return "VEKTA:PRODUCT:\(sku ?? ""):\(sellerId)"
    }
}
