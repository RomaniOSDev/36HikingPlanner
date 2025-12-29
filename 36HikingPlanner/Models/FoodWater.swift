//
//  FoodWater.swift
//  36HikingPlanner
//
//  Created by Роман Главацкий on 24.12.2025.
//

import Foundation

struct FoodWaterCalculation: Codable {
    var waterPerPerson: Double // liters per person
    var caloriesPerPerson: Int // calories per person
    var meals: [Meal]
    var snacks: [Snack]
    
    var totalWater: Double {
        waterPerPerson // multiplied by group size in UI
    }
    
    var totalWeight: Double { // kg
        let waterWeight = totalWater * 1.0 // 1L = 1kg
        let foodWeight = Double(caloriesPerPerson) / 1000.0 * 0.5 // approximate formula
        return waterWeight + foodWeight
    }
}

struct Meal: Identifiable, Codable {
    let id: UUID
    var name: String
    var timeOfDay: TimeOfDay
    var calories: Int
    var preparationTime: TimeInterval // minutes
    var ingredients: [String]
}

enum TimeOfDay: String, CaseIterable, Codable {
    case breakfast = "Breakfast"
    case lunch = "Lunch"
    case dinner = "Dinner"
}

struct Snack: Identifiable, Codable {
    let id: UUID
    var name: String
    var calories: Int
    var quantity: Int
}

