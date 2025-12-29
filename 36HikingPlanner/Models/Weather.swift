//
//  Weather.swift
//  36HikingPlanner
//
//  Created by Роман Главацкий on 24.12.2025.
//

import Foundation

struct WeatherForecast: Codable {
    var temperature: TemperatureRange
    var precipitation: Double // mm
    var windSpeed: Double // m/s
    var sunrise: Date
    var sunset: Date
    var conditions: WeatherConditions
    
    var daylightHours: TimeInterval {
        sunset.timeIntervalSince(sunrise)
    }
    
    var isSafeForHiking: Bool {
        precipitation < 10.0 && windSpeed < 15.0
    }
}

struct TemperatureRange: Codable {
    var min: Double // °C
    var max: Double // °C
    var feelsLike: Double // °C
}

enum WeatherConditions: String, CaseIterable, Codable {
    case clear = "Clear"
    case partlyCloudy = "Partly Cloudy"
    case cloudy = "Cloudy"
    case rain = "Rain"
    case snow = "Snow"
    case storm = "Storm"
    case fog = "Fog"
}

struct EmergencyContact: Identifiable, Codable {
    let id: UUID
    var name: String
    var phone: String
    var relationship: String
    var notes: String?
}

