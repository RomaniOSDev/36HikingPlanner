//
//  WeatherViewModel.swift
//  36HikingPlanner
//
//  Created by Роман Главацкий on 24.12.2025.
//

import Foundation
import SwiftUI
import Combine

class WeatherViewModel: ObservableObject {
    @Published var currentForecast: WeatherForecast?
    @Published var isLoading = false
    @Published var safetyWarnings: [SafetyWarning] = []
    
    func fetchWeatherForecast(for date: Date, location: String = "Default") {
        isLoading = true
        
        // Mock weather data for MVP
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let calendar = Calendar.current
            let sunrise = calendar.date(bySettingHour: 6, minute: 30, second: 0, of: date) ?? date
            let sunset = calendar.date(bySettingHour: 19, minute: 0, second: 0, of: date) ?? date
            
            self.currentForecast = WeatherForecast(
                temperature: TemperatureRange(min: 15, max: 25, feelsLike: 20),
                precipitation: 5.0,
                windSpeed: 8.0,
                sunrise: sunrise,
                sunset: sunset,
                conditions: .partlyCloudy
            )
            
            self.isLoading = false
        }
    }
    
    func analyzeSafety(route: HikingRoute, plan: HikePlan) {
        safetyWarnings = SafetyAnalyzer.analyzeRouteSafety(route: route, plan: plan, weather: currentForecast)
    }
    
    var isSafeForHiking: Bool {
        currentForecast?.isSafeForHiking ?? true
    }
    
    var daylightHours: TimeInterval {
        currentForecast?.daylightHours ?? 0
    }
}

