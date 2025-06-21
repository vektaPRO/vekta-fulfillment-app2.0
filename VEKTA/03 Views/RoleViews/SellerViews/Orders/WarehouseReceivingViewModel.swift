import Foundation
import SwiftUI
import FirebaseFirestore
import FirebaseAuth

final class WarehouseReceivingViewModel: ObservableObject {
    @Published var shipments: [ShipmentModel] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var successMessage: String?

    private let db = Firestore.firestore()

    var pendingCount: Int {
        shipments.filter { $0.status == .created }.count
    }

    var processingCount: Int {
        shipments.filter { $0.status == .processing }.count
    }

    var completedCount: Int {
        shipments.filter { $0.status == .ready || $0.status == .delivered }.count
    }

    func loadShipments() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        isLoading = true
        db.collection("shipments")
            .whereField("warehouseId", isEqualTo: uid)
            .whereField("type", isEqualTo: ShipmentType.incoming.rawValue)
            .getDocuments { [weak self] snapshot, error in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    if let error = error {
                        self?.errorMessage = error.localizedDescription
                    } else {
                        self?.shipments = snapshot?.documents.compactMap { try? $0.data(as: ShipmentModel.self) } ?? []
                    }
                }
            }
    }

    func confirmReception(for code: String) {
        guard let shipment = shipments.first(where: { $0.qrCode == code || $0.id == code }) else {
            errorMessage = "Приемка не найдена"
            return
        }
        updateShipmentStatus(shipmentId: shipment.id ?? "")
    }

    private func updateShipmentStatus(shipmentId: String) {
        isLoading = true
        db.collection("shipments").document(shipmentId).updateData([
            "status": ShipmentStatus.processing.rawValue,
            "updatedAt": Date()
        ]) { [weak self] error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                } else {
                    self?.successMessage = "Приемка подтверждена"
                    self?.loadShipments()
                }
            }
        }
    }
}
