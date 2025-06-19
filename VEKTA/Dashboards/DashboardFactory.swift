// MARK: - DashboardFactory.swift
import SwiftUI

struct DashboardFactory {
    static func createDashboard(for role: UserRole, user: UserModel) -> some View {
        switch role {
        case .superadmin:
            return AnyView(SuperAdminDashboard(user: user))
        case .warehouseAdmin:
            return AnyView(WarehouseAdminDashboard(user: user))
        case .seller:
            return AnyView(SellerDashboard(user: user))
        case .courier:
            return AnyView(CourierDashboard(user: user))
        }
    }
}
