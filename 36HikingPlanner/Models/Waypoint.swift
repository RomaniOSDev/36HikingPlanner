//
//  Waypoint.swift
//  36HikingPlanner
//
//  Created by Роман Главацкий on 24.12.2025.
//

import Foundation
import SwiftUI

struct Waypoint: Identifiable, Codable {
    let id: UUID
    var name: String
    var distanceFromStart: Double // km
    var elevation: Double // meters
    var type: WaypointType
    var notes: String?
    var estimatedTimeFromStart: TimeInterval? // hours
    var isWaterSource: Bool
    var isCampSite: Bool
    var dangerLevel: DangerLevel
    
    var color: Color {
        switch type {
        case .start: return Color(hex: "2FAE4D")
        case .end: return Color(hex: "A40D01")
        case .landmark: return Color(hex: "FFD700")
        case .water: return Color(hex: "1E90FF")
        case .camp: return Color(hex: "8B4513")
        case .viewpoint: return Color(hex: "FF8C00")
        case .danger: return Color(hex: "FF0000")
        }
    }
}

enum WaypointType: String, CaseIterable, Codable {
    case start = "Start"
    case end = "End"
    case landmark = "Landmark"
    case water = "Water Source"
    case camp = "Campsite"
    case viewpoint = "Viewpoint"
    case danger = "Danger Zone"
}

enum DangerLevel: String, CaseIterable, Codable {
    case none = "None"
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    case extreme = "Extreme"
    
    var color: Color {
        switch self {
        case .none: return Color(hex: "2FAE4D")
        case .low: return Color(hex: "FFD700")
        case .medium: return Color(hex: "FF8C00")
        case .high: return Color(hex: "FF4500")
        case .extreme: return Color(hex: "A40D01")
        }
    }
}

