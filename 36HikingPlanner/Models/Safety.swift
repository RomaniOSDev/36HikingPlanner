//
//  Safety.swift
//  36HikingPlanner
//
//  Created by Роман Главацкий on 24.12.2025.
//

import Foundation
import SwiftUI

struct SafetyWarning: Identifiable {
    let id = UUID()
    var type: WarningType
    var severity: WarningSeverity
    var message: String
    var recommendation: String
}

enum WarningType: String {
    case difficultyMismatch = "Difficulty Mismatch"
    case nightHiking = "Night Hiking"
    case dangerousSections = "Dangerous Sections"
    case waterShortage = "Water Shortage"
    case weatherRisk = "Weather Risk"
    case timeShortage = "Time Shortage"
}

enum WarningSeverity: String {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    case critical = "Critical"
    
    var color: Color {
        switch self {
        case .low: return Color(hex: "2FAE4D")
        case .medium: return Color(hex: "FFD700")
        case .high: return Color(hex: "FF8C00")
        case .critical: return Color(hex: "A40D01")
        }
    }
}

