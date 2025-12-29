//
//  EquipmentViewModel.swift
//  36HikingPlanner
//
//  Created by Роман Главацкий on 24.12.2025.
//

import Foundation
import SwiftUI
import Combine

class EquipmentViewModel: ObservableObject {
    @Published var equipmentItems: [EquipmentItem] = []
    @Published var selectedCategory: EquipmentCategory?
    @Published var totalWeight: Double = 0.0
    
    func loadEquipment(for season: Season) {
        equipmentItems = EquipmentTemplates.getTemplate(for: season)
        calculateTotalWeight()
    }
    
    func addEquipment(_ item: EquipmentItem) {
        equipmentItems.append(item)
        calculateTotalWeight()
    }
    
    func updateEquipment(_ item: EquipmentItem) {
        if let index = equipmentItems.firstIndex(where: { $0.id == item.id }) {
            equipmentItems[index] = item
            calculateTotalWeight()
        }
    }
    
    func deleteEquipment(_ item: EquipmentItem) {
        equipmentItems.removeAll { $0.id == item.id }
        calculateTotalWeight()
    }
    
    func togglePacked(_ item: EquipmentItem) {
        if let index = equipmentItems.firstIndex(where: { $0.id == item.id }) {
            equipmentItems[index].isPacked.toggle()
        }
    }
    
    func calculateTotalWeight() {
        totalWeight = equipmentItems.reduce(0.0) { $0 + (($1.weight ?? 0) * Double($1.quantity)) }
    }
    
    func getEquipmentByCategory(_ category: EquipmentCategory) -> [EquipmentItem] {
        return equipmentItems.filter { $0.category == category }
    }
    
    var packedCount: Int {
        equipmentItems.filter { $0.isPacked }.count
    }
    
    var totalCount: Int {
        equipmentItems.count
    }
    
    var packingProgress: Double {
        guard totalCount > 0 else { return 0 }
        return Double(packedCount) / Double(totalCount)
    }
}

