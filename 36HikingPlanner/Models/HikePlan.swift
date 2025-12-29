//
//  HikePlan.swift
//  36HikingPlanner
//
//  Created by Роман Главацкий on 24.12.2025.
//

import Foundation

struct HikePlan: Identifiable, Codable {
    let id: UUID
    var routeId: UUID
    var plannedDate: Date
    var groupSize: Int
    var hikerLevel: HikerExperience
    var weatherConditions: WeatherForecast?
    var timeSlots: [TimeSlot]
    var equipmentChecklist: [EquipmentItem]
    var foodWaterPlan: FoodWaterCalculation
    var emergencyContacts: [EmergencyContact]
    var notes: String?
    
    var totalHikeTime: TimeInterval {
        timeSlots.reduce(0) { $0 + $1.duration }
    }
    
    var startTime: Date? {
        timeSlots.first?.startTime
    }
    
    var endTime: Date? {
        guard let firstStart = startTime else { return nil }
        return Calendar.current.date(byAdding: .second, value: Int(totalHikeTime), to: firstStart)
    }
}

enum HikerExperience: String, CaseIterable, Codable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"
    case expert = "Expert"
    
    var basePace: Double { // km/h
        switch self {
        case .beginner: return 3.0
        case .intermediate: return 4.0
        case .advanced: return 4.5
        case .expert: return 5.0
        }
    }
}

struct TimeSlot: Identifiable, Codable {
    let id: UUID
    var activity: HikeActivity
    var startTime: Date
    var duration: TimeInterval // minutes
    var distanceCovered: Double? // km
    var notes: String?
    
    var endTime: Date {
        Calendar.current.date(byAdding: .second, value: Int(duration), to: startTime) ?? startTime
    }
}

enum HikeActivity: String, CaseIterable, Codable {
    case hiking = "Hiking"
    case rest = "Rest"
    case lunch = "Lunch"
    case photography = "Photography"
    case sightseeing = "Sightseeing"
    case setupCamp = "Setup Camp"
    
    var icon: String {
        switch self {
        case .hiking: return "figure.walk"
        case .rest: return "bed.double"
        case .lunch: return "fork.knife"
        case .photography: return "camera"
        case .sightseeing: return "binoculars"
        case .setupCamp: return "tent"
        }
    }
}

