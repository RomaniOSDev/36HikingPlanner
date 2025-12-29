//
//  WeatherSafetyView.swift
//  36HikingPlanner
//
//  Created by Роман Главацкий on 24.12.2025.
//

import SwiftUI

struct WeatherSafetyView: View {
    @ObservedObject var viewModel: WeatherViewModel
    let plan: HikePlan
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    if viewModel.isLoading {
                        ProgressView()
                            .padding()
                    } else if let forecast = viewModel.currentForecast {
                        // Weather Overview
                        weatherOverviewSection(forecast: forecast)
                        
                        // Safety Warnings
                        if !viewModel.safetyWarnings.isEmpty {
                            safetyWarningsSection
                        }
                        
                        // Recommendations
                        recommendationsSection(forecast: forecast)
                    } else {
                        Text("No weather data available")
                            .foregroundColor(.hikingTextSecondary)
                            .padding()
                    }
                }
                .padding()
            }
            .background(Color.hikingBackground)
            .navigationTitle("Weather & Safety")
            .navigationBarTitleDisplayMode(.large)
            .preferredColorScheme(.dark)
            .onAppear {
                viewModel.fetchWeatherForecast(for: plan.plannedDate)
            }
        }
    }
    
    private func weatherOverviewSection(forecast: WeatherForecast) -> some View {
        VStack(spacing: 16) {
            Text("Weather Forecast")
                .font(.headline)
                .foregroundColor(.hikingTextPrimary)
            
            // Temperature
            HStack {
                VStack {
                    Text("\(Int(forecast.temperature.min))°")
                        .font(.title2)
                        .foregroundColor(.hikingTextSecondary)
                    Text("Min")
                        .font(.caption)
                        .foregroundColor(.hikingTextSecondary)
                }
                
                Spacer()
                
                VStack {
                    Text("\(Int(forecast.temperature.max))°")
                        .font(.title)
                        .foregroundColor(.hikingTextPrimary)
                    Text("Temperature")
                        .font(.caption)
                        .foregroundColor(.hikingTextSecondary)
                }
                
                Spacer()
                
                VStack {
                    Text("\(Int(forecast.temperature.feelsLike))°")
                        .font(.title2)
                        .foregroundColor(.hikingTextSecondary)
                    Text("Feels Like")
                        .font(.caption)
                        .foregroundColor(.hikingTextSecondary)
                }
            }
            
            // Conditions
            HStack {
                Text(forecast.conditions.rawValue)
                    .font(.headline)
                    .foregroundColor(.hikingTextPrimary)
                
                Spacer()
                
                if forecast.isSafeForHiking {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.hikingAccent1)
                        Text("Safe")
                            .foregroundColor(.hikingAccent1)
                    }
                } else {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.hikingAccent2)
                        Text("Unsafe")
                            .foregroundColor(.hikingAccent2)
                    }
                }
            }
            
            // Additional Info
            HStack(spacing: 20) {
                VStack {
                    Text("\(String(format: "%.1f", forecast.precipitation))")
                        .font(.title3)
                        .foregroundColor(.hikingWater)
                    Text("Precipitation (mm)")
                        .font(.caption)
                        .foregroundColor(.hikingTextSecondary)
                }
                
                VStack {
                    Text("\(String(format: "%.1f", forecast.windSpeed))")
                        .font(.title3)
                        .foregroundColor(.hikingTextPrimary)
                    Text("Wind Speed (m/s)")
                        .font(.caption)
                        .foregroundColor(.hikingTextSecondary)
                }
            }
            
            // Sunrise/Sunset
            HStack {
                VStack {
                    Text(forecast.sunrise, style: .time)
                        .font(.headline)
                        .foregroundColor(.hikingGold)
                    Text("Sunrise")
                        .font(.caption)
                        .foregroundColor(.hikingTextSecondary)
                }
                
                Spacer()
                
                VStack {
                    Text("\(Int(forecast.daylightHours / 3600))h \(Int((forecast.daylightHours.truncatingRemainder(dividingBy: 3600)) / 60))m")
                        .font(.headline)
                        .foregroundColor(.hikingTextPrimary)
                    Text("Daylight Hours")
                        .font(.caption)
                        .foregroundColor(.hikingTextSecondary)
                }
                
                Spacer()
                
                VStack {
                    Text(forecast.sunset, style: .time)
                        .font(.headline)
                        .foregroundColor(.hikingAccent2)
                    Text("Sunset")
                        .font(.caption)
                        .foregroundColor(.hikingTextSecondary)
                }
            }
        }
        .padding()
        .background(Color.hikingBackground.opacity(0.5))
        .cornerRadius(16)
    }
    
    private var safetyWarningsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Safety Warnings")
                .font(.headline)
                .foregroundColor(.hikingTextPrimary)
            
            ForEach(viewModel.safetyWarnings) { warning in
                SafetyWarningCard(warning: warning)
            }
        }
    }
    
    private func recommendationsSection(forecast: WeatherForecast) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recommendations")
                .font(.headline)
                .foregroundColor(.hikingTextPrimary)
            
            VStack(alignment: .leading, spacing: 8) {
                if forecast.temperature.min < 10 {
                    RecommendationRow(icon: "thermometer.snowflake", text: "Bring warm clothing")
                }
                
                if forecast.precipitation > 5 {
                    RecommendationRow(icon: "cloud.rain.fill", text: "Bring waterproof gear")
                }
                
                if forecast.windSpeed > 10 {
                    RecommendationRow(icon: "wind", text: "Be cautious in exposed areas")
                }
                
                if !forecast.isSafeForHiking {
                    RecommendationRow(icon: "exclamationmark.triangle.fill", text: "Consider postponing the hike")
                }
            }
        }
        .padding()
        .background(Color.hikingBackground.opacity(0.5))
        .cornerRadius(12)
    }
}

struct SafetyWarningCard: View {
    let warning: SafetyWarning
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(warning.severity.color)
                Text(warning.type.rawValue)
                    .font(.headline)
                    .foregroundColor(.hikingTextPrimary)
                Spacer()
                Text(warning.severity.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(warning.severity.color.opacity(0.3))
                    .foregroundColor(warning.severity.color)
                    .cornerRadius(8)
            }
            
            Text(warning.message)
                .font(.subheadline)
                .foregroundColor(.hikingTextPrimary)
            
            Text(warning.recommendation)
                .font(.caption)
                .foregroundColor(.hikingTextSecondary)
        }
        .padding()
        .background(warning.severity.color.opacity(0.1))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(warning.severity.color.opacity(0.3), lineWidth: 1)
        )
    }
}

struct RecommendationRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.hikingAccent1)
            Text(text)
                .foregroundColor(.hikingTextPrimary)
        }
    }
}

