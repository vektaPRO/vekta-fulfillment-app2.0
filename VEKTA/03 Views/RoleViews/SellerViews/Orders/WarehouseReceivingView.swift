import SwiftUI
import FirebaseFirestore
import AVFoundation

// MARK: - Warehouse Receiving View
struct WarehouseReceivingView: View {
    @StateObject private var viewModel = WarehouseReceivingViewModel()
    @State private var showingScanner = false
    @State private var showingManualInput = false
    @State private var selectedShipment: ShipmentModel?
    
    var body: some View {
        NavigationView {
            VStack {
                // Статистика дня
                DailyStatsView(viewModel: viewModel)
                    .padding()
                
                // Список приемок
                if viewModel.isLoading {
                    ProgressView("Загрузка приемок...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.shipments.isEmpty {
                    EmptyReceivingState()
                } else {
                    List {
                        ForEach(viewModel.shipments) { shipment in
                            ShipmentRow(shipment: shipment) {
                                selectedShipment = shipment
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                }
                
                // Кнопки действий
                HStack(spacing: 16) {
                    Button(action: { showingScanner = true }) {
                        HStack {
                            Image(systemName: "qrcode.viewfinder")
                            Text("Сканировать QR")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.brandGreen)
                        .cornerRadius(12)
                    }
                    
                    Button(action: { showingManualInput = true }) {
                        Image(systemName: "keyboard")
                            .font(.headline)
                            .foregroundColor(.brandGreen)
                            .frame(width: 50, height: 50)
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                    }
                }
                .padding()
            }
            .navigationTitle("Приемка товаров")
            .sheet(isPresented: $showingScanner) {
                QRScannerView { qrCode in
                    viewModel.processQRCode(qrCode)
                    showingScanner = false
                }
            }
            .sheet(isPresented: $showingManualInput) {
                ManualShipmentInputView { shipmentId in
                    viewModel.loadShipment(by: shipmentId)
                    showingManualInput = false
                }
            }
            .sheet(item: $selectedShipment) { shipment in
                ShipmentDetailView(shipment: shipment)
            }
        }
        .onAppear {
            viewModel.loadShipments()
        }
    }
}

// MARK: - Daily Stats View
struct DailyStatsView: View {
    @ObservedObject var viewModel: WarehouseReceivingViewModel
    
    var body: some View {
        HStack(spacing: 16) {
            StatMiniCard(
                title: "Ожидают",
                value: "\(viewModel.pendingCount)",
                color: .orange
            )
            
            StatMiniCard(
                title: "В процессе",
                value: "\(viewModel.processingCount)",
                color: .blue
            )
            
            StatMiniCard(
                title: "Принято",
                value: "\(viewModel.completedCount)",
                color: .green
            )
        }
    }
}

struct StatMiniCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

// MARK: - Empty State
struct EmptyReceivingState: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "tray")
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.3))
            
            Text("Нет активных приемок")
                .font(.title3)
                .fontWeight(.medium)
            
            Text("Отсканируйте QR-код или введите номер приемки")
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

// MARK: - Shipment Row
struct ShipmentRow: View {
    let shipment: ShipmentModel
    let onTap: () -> Void
    
    var statusColor: Color {
        switch shipment.status {
        case .created: return .orange
        case .processing: return .blue
        case .ready, .delivered: return .green
        case .cancelled: return .red
        default: return .gray
        }
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Приемка #\(String(shipment.id?.prefix(8) ?? ""))")
                            .font(.headline)
                        
                        if let sellerId = shipment.sellerId {
                            Text("От: \(sellerId)") // TODO: Загрузить имя селлера
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Spacer()
                    
                    Text(shipment.status.displayName)
                        .font(.caption)
                        .fontWeight(.medium)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(statusColor.opacity(0.1))
                        .foregroundColor(statusColor)
                        .cornerRadius(12)
                }
                
                HStack {
                    Label("\(shipment.products.count) товаров", systemImage: "cube.box")
                    Spacer()
                    Label("\(shipment.products.reduce(0) { $0 + $1.quantity }) шт", systemImage: "number")
                }
                .font(.caption)
                .foregroundColor(.gray)
                
                Text(shipment.createdAt.formatted())
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Shipment Detail View
struct ShipmentDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel: ShipmentDetailViewModel
    let shipment: ShipmentModel
    
    init(shipment: ShipmentModel) {
        self.shipment = shipment
        self._viewModel = StateObject(wrappedValue: ShipmentDetailViewModel(shipment: shipment))
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Информация о приемке
                    ShipmentInfoCard(shipment: shipment)
                    
                    // Список товаров
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Товары в приемке")
                            .font(.headline)
                        
                        ForEach(viewModel.productItems) { item in
                            ProductReceivingCard(
                                item: item,
                                onScan: {
                                    viewModel.scanProduct(item.product.productId)
                                },
                                onManualReceive: { quantity in
                                    viewModel.receiveProduct(item.product.productId, quantity: quantity)
                                }
                            )
                        }
                    }
                    .padding(.horizontal)
                    
                    // Кнопка завершения
                    if viewModel.canComplete {
                        Button(action: {
                            viewModel.completeReceiving {
                                presentationMode.wrappedValue.dismiss()
                            }
                        }) {
                            if viewModel.isProcessing {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Завершить приемку")
                                    .font(.headline)
                                    .foregroundColor(.white)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.brandGreen)
                        .cornerRadius(12)
                        .disabled(viewModel.isProcessing)
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Детали приемки")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Закрыть") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Shipment Info Card
struct ShipmentInfoCard: View {
    let shipment: ShipmentModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("ID приемки")
                    .font(.caption)
                    .foregroundColor(.gray)
                Spacer()
                Text(String(shipment.id?.prefix(8) ?? ""))
                    .font(.caption)
                    .fontWeight(.medium)
            }
            
            HStack {
                Text("Статус")
                    .font(.caption)
                    .foregroundColor(.gray)
                Spacer()
                Text(shipment.status.displayName)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.brandGreen)
            }
            
            HStack {
                Text("Код подтверждения")
                    .font(.caption)
                    .foregroundColor(.gray)
                Spacer()
                Text(shipment.verificationCode ?? "------")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

// MARK: - Product Receiving Card
struct ProductReceivingCard: View {
    let item: ProductReceivingItem
    let onScan: () -> Void
    let onManualReceive: (Int) -> Void
    
    @State private var manualQuantity = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.product.productName)
                        .font(.headline)
                    Text("Ожидается: \(item.product.quantity) шт")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                if item.isReceived {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.title2)
                } else {
                    Button(action: onScan) {
                        Image(systemName: "qrcode.viewfinder")
                            .foregroundColor(.brandGreen)
                            .font(.title2)
                    }
                }
            }
            
            if !item.isReceived {
                HStack {
                    TextField("Количество", text: $manualQuantity)
                        .keyboardType(.numberPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 100)
                    
                    Button("Принять") {
                        if let quantity = Int(manualQuantity) {
                            onManualReceive(quantity)
                        }
                    }
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.brandGreen)
                    .cornerRadius(8)
                    
                    Spacer()
                }
            } else {
                HStack {
                    Text("Принято: \(item.receivedQuantity) шт")
                        .font(.caption)
                        .foregroundColor(.green)
                    
                    if item.receivedQuantity != item.product.quantity {
                        Text("(расхождение: \(item.receivedQuantity - item.product.quantity))")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - View Models
