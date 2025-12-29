//
//  Equipment.swift
//  36HikingPlanner
//
//  Created by Роман Главацкий on 24.12.2025.
//

import Foundation

struct EquipmentItem: Identifiable, Codable {
    let id: UUID
    var name: String
    var category: EquipmentCategory
    var isEssential: Bool
    var quantity: Int
    var weight: Double? // kg
    var isPacked: Bool = false
    var notes: String?
}

enum EquipmentCategory: String, CaseIterable, Codable {
    case clothing = "Clothing"
    case footwear = "Footwear"
    case navigation = "Navigation"
    case shelter = "Shelter"
    case sleep = "Sleep"
    case cooking = "Cooking"
    case hydration = "Hydration"
    case firstAid = "First Aid"
    case tools = "Tools"
    case other = "Other"
}

