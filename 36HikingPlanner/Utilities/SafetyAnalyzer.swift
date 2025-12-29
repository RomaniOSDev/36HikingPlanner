//
//  SafetyAnalyzer.swift
//  36HikingPlanner
//
//  Created by Роман Главацкий on 24.12.2025.
//

import Foundation

struct SafetyAnalyzer {
    static func analyzeRouteSafety(route: HikingRoute, plan: HikePlan, weather: WeatherForecast?) -> [SafetyWarning] {
        var warnings: [SafetyWarning] = []
        
        // Check route difficulty vs group experience
        let averageExperience = plan.hikerLevel
        if (route.difficulty == .hard || route.difficulty == .extreme) && averageExperience == .beginner {
            warnings.append(SafetyWarning(
                type: .difficultyMismatch,
                severity: .high,
                message: "Route is too difficult for beginners",
                recommendation: "Choose an easier route or hire a guide"
            ))
        }
        
        // Check route completion time
        if let endTime = plan.endTime, let sunset = weather?.sunset {
            if endTime > sunset {
                warnings.append(SafetyWarning(
                    type: .nightHiking,
                    severity: .medium,
                    message: "Hike will finish after sunset",
                    recommendation: "Start earlier or shorten the route"
                ))
            }
        }
        
        // Check dangerous sections
        let dangerousWaypoints = route.waypoints.filter { $0.dangerLevel == .high || $0.dangerLevel == .extreme }
        if !dangerousWaypoints.isEmpty {
            warnings.append(SafetyWarning(
                type: .dangerousSections,
                severity: .high,
                message: "Route has \(dangerousWaypoints.count) dangerous sections",
                recommendation: "Be cautious, check your equipment"
            ))
        }
        
        // Check water sources
        let waterSources = route.waypoints.filter { $0.isWaterSource }
        if waterSources.isEmpty && route.totalDistance > 10 {
            warnings.append(SafetyWarning(
                type: .waterShortage,
                severity: .medium,
                message: "No water sources on route",
                recommendation: "Bring enough water: \(String(format: "%.1f", plan.foodWaterPlan.totalWater))L"
            ))
        }
        
        // Check weather
        if let weather = weather, !weather.isSafeForHiking {
            warnings.append(SafetyWarning(
                type: .weatherRisk,
                severity: .high,
                message: "Unsafe weather conditions",
                recommendation: "Consider postponing or prepare for severe weather"
            ))
        }
        
        return warnings
    }
}

