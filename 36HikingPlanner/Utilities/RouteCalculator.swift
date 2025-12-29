//
//  RouteCalculator.swift
//  36HikingPlanner
//
//  Created by Роман Главацкий on 24.12.2025.
//

import Foundation

struct RouteCalculator {
    static func calculateHikeTime(route: HikingRoute, hikerLevel: HikerExperience) -> TimeInterval {
        let basePace = hikerLevel.basePace // km/h
        
        // Adjust pace for route difficulty
        let difficultyMultiplier = route.difficulty.paceMultiplier
        
        // Adjust for elevation gain (Naismith's rule)
        let elevationFactor = 1.0 + (route.elevationGain / 300.0) // +1 hour per 300m ascent
        
        let adjustedPace = basePace / difficultyMultiplier / elevationFactor
        
        // Total time in hours
        let hikingTime = route.totalDistance / adjustedPace
        
        // Add rest time (10 minutes per hour of hiking)
        let restTime = hikingTime * (10.0 / 60.0)
        
        // Convert to seconds
        return (hikingTime + restTime) * 3600.0
    }
    
    static func estimateCalorieBurn(route: HikingRoute, weight: Double) -> Int {
        // Formula: 0.5 kcal per kg weight per km on flat surface
        let baseCalories = 0.5 * weight * route.totalDistance
        
        // Add for elevation gain: 1 kcal per kg weight per 10m ascent
        let elevationCalories = 1.0 * weight * (route.elevationGain / 10.0)
        
        return Int(baseCalories + elevationCalories)
    }
    
    static func calculateWaterNeeds(route: HikingRoute, temperature: Double, duration: TimeInterval) -> Double {
        let baseWaterPerHour = 0.5 // liters per hour
        
        // Adjust for temperature
        let tempFactor: Double
        switch temperature {
        case ..<10: tempFactor = 0.8
        case 10..<20: tempFactor = 1.0
        case 20..<30: tempFactor = 1.3
        default: tempFactor = 1.5
        }
        
        // Adjust for difficulty
        let difficultyFactor = route.difficulty.paceMultiplier
        
        let hours = duration / 3600.0
        return baseWaterPerHour * hours * tempFactor * difficultyFactor
    }
}

