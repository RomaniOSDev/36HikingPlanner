//
//  HikingRoute.swift
//  36HikingPlanner
//
//  Created by Роман Главацкий on 24.12.2025.
//

import Foundation
import SwiftUI

struct HikingRoute: Identifiable, Codable {
    let id: UUID
    var name: String
    var description: String
    var totalDistance: Double // kilometers
    var estimatedTime: TimeInterval // hours
    var elevationGain: Double // meters
    var elevationLoss: Double // meters
    var difficulty: DifficultyLevel
    var season: Season
    var waypoints: [Waypoint]
    var createdDate: Date
    var lastHiked: Date?
    
    var netElevationChange: Double {
        elevationGain - elevationLoss
    }
    
    var averageGrade: Double {
        guard totalDistance > 0 else { return 0 }
        return (elevationGain / (totalDistance * 1000)) * 100 // %
    }
    
    var difficultyColor: Color {
        switch difficulty {
        case .easy: return Color(hex: "2FAE4D")
        case .moderate: return Color(hex: "FFD700")
        case .hard: return Color(hex: "FF8C00")
        case .extreme: return Color(hex: "A40D01")
        }
    }
}

enum DifficultyLevel: String, CaseIterable, Codable {
    case easy = "Easy"
    case moderate = "Moderate"
    case hard = "Hard"
    case extreme = "Extreme"
    
    var paceMultiplier: Double {
        switch self {
        case .easy: return 1.0
        case .moderate: return 1.3
        case .hard: return 1.7
        case .extreme: return 2.2
        }
    }
}

enum Season: String, CaseIterable, Codable {
    case spring = "Spring"
    case summer = "Summer"
    case autumn = "Autumn"
    case winter = "Winter"
    case allSeason = "All Season"
}

