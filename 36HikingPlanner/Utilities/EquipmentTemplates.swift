//
//  EquipmentTemplates.swift
//  36HikingPlanner
//
//  Created by Роман Главацкий on 24.12.2025.
//

import Foundation

struct EquipmentTemplates {
    static let defaultEquipmentTemplates: [Season: [EquipmentItem]] = [
        .summer: [
            EquipmentItem(id: UUID(), name: "Trekking Poles", category: .tools, isEssential: true, quantity: 2, weight: 0.5, isPacked: false, notes: nil),
            EquipmentItem(id: UUID(), name: "Sunscreen", category: .other, isEssential: true, quantity: 1, weight: 0.1, isPacked: false, notes: nil),
            EquipmentItem(id: UUID(), name: "Cap/Hat", category: .clothing, isEssential: true, quantity: 1, weight: 0.1, isPacked: false, notes: nil),
            EquipmentItem(id: UUID(), name: "Light Jacket", category: .clothing, isEssential: true, quantity: 1, weight: 0.3, isPacked: false, notes: nil),
        ],
        .winter: [
            EquipmentItem(id: UUID(), name: "Thermal Underwear", category: .clothing, isEssential: true, quantity: 1, weight: 0.3, isPacked: false, notes: nil),
            EquipmentItem(id: UUID(), name: "Down Jacket", category: .clothing, isEssential: true, quantity: 1, weight: 0.8, isPacked: false, notes: nil),
            EquipmentItem(id: UUID(), name: "Thermos", category: .hydration, isEssential: true, quantity: 1, weight: 0.5, isPacked: false, notes: nil),
            EquipmentItem(id: UUID(), name: "Snowshoes", category: .footwear, isEssential: true, quantity: 1, weight: 1.5, isPacked: false, notes: nil),
        ],
        .spring: [
            EquipmentItem(id: UUID(), name: "Waterproof Jacket", category: .clothing, isEssential: true, quantity: 1, weight: 0.4, isPacked: false, notes: nil),
            EquipmentItem(id: UUID(), name: "Insect Repellent", category: .other, isEssential: true, quantity: 1, weight: 0.1, isPacked: false, notes: nil),
            EquipmentItem(id: UUID(), name: "Rain Poncho", category: .clothing, isEssential: true, quantity: 1, weight: 0.2, isPacked: false, notes: nil),
        ],
        .autumn: [
            EquipmentItem(id: UUID(), name: "Warm Gloves", category: .clothing, isEssential: true, quantity: 1, weight: 0.2, isPacked: false, notes: nil),
            EquipmentItem(id: UUID(), name: "Thermal Underwear", category: .clothing, isEssential: true, quantity: 1, weight: 0.3, isPacked: false, notes: nil),
            EquipmentItem(id: UUID(), name: "Flashlight", category: .tools, isEssential: true, quantity: 1, weight: 0.3, isPacked: false, notes: nil),
        ],
        .allSeason: [
            EquipmentItem(id: UUID(), name: "Backpack", category: .other, isEssential: true, quantity: 1, weight: 1.5, isPacked: false, notes: nil),
            EquipmentItem(id: UUID(), name: "First Aid Kit", category: .firstAid, isEssential: true, quantity: 1, weight: 0.5, isPacked: false, notes: nil),
            EquipmentItem(id: UUID(), name: "Map & Compass", category: .navigation, isEssential: true, quantity: 1, weight: 0.2, isPacked: false, notes: nil),
            EquipmentItem(id: UUID(), name: "Water Bottle", category: .hydration, isEssential: true, quantity: 1, weight: 0.3, isPacked: false, notes: nil),
        ]
    ]
    
    static func getTemplate(for season: Season) -> [EquipmentItem] {
        return defaultEquipmentTemplates[season] ?? []
    }
}

