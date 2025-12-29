//
//  PlanCreatorView.swift
//  36HikingPlanner
//
//  Created by Роман Главацкий on 24.12.2025.
//

import SwiftUI

struct PlanCreatorView: View {
    @ObservedObject var routeViewModel: RouteViewModel
    @ObservedObject var planViewModel: PlanViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedRoute: HikingRoute?
    @State private var groupSize: Int = 1
    @State private var hikerLevel: HikerExperience = .intermediate
    @State private var plannedDate: Date = Date()
    @State private var currentStep = 0
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Progress Indicator
                ProgressView(value: Double(currentStep), total: 3)
                    .progressViewStyle(LinearProgressViewStyle(tint: .hikingAccent1))
                    .padding()
                
                ScrollView {
                    VStack(spacing: 24) {
                        if currentStep == 0 {
                            routeSelectionStep
                        } else if currentStep == 1 {
                            groupInfoStep
                        } else {
                            dateSelectionStep
                        }
                    }
                    .padding()
                }
                
                // Navigation Buttons
                HStack {
                    if currentStep > 0 {
                        Button("Back") {
                            withAnimation {
                                currentStep -= 1
                            }
                        }
                        .foregroundColor(.hikingTextSecondary)
                    }
                    
                    Spacer()
                    
                    Button(currentStep == 2 ? "Create Plan" : "Next") {
                        if currentStep == 2 {
                            createPlan()
                        } else {
                            withAnimation {
                                currentStep += 1
                            }
                        }
                    }
                    .foregroundColor(.hikingAccent1)
                    .disabled(currentStep == 0 && selectedRoute == nil)
                }
                .padding()
            }
            .background(Color.hikingBackground)
            .navigationTitle("New Hike Plan")
            .navigationBarTitleDisplayMode(.inline)
            .preferredColorScheme(.dark)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.hikingTextSecondary)
                }
            }
        }
    }
    
    private var routeSelectionStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Select Route")
                .font(.title2)
                .foregroundColor(.hikingTextPrimary)
            
            if routeViewModel.routes.isEmpty {
                Text("No routes available. Please create a route first.")
                    .foregroundColor(.hikingTextSecondary)
                    .padding()
            } else {
                ForEach(routeViewModel.routes) { route in
                    RouteSelectionCard(
                        route: route,
                        isSelected: selectedRoute?.id == route.id
                    ) {
                        selectedRoute = route
                    }
                }
            }
        }
    }
    
    private var groupInfoStep: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Group Information")
                .font(.title2)
                .foregroundColor(.hikingTextPrimary)
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Group Size")
                    .font(.headline)
                    .foregroundColor(.hikingTextPrimary)
                
                Stepper(value: $groupSize, in: 1...20) {
                    Text("\(groupSize) person\(groupSize == 1 ? "" : "s")")
                        .foregroundColor(.hikingTextPrimary)
                }
            }
            .padding()
            .background(Color.hikingBackground.opacity(0.5))
            .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Experience Level")
                    .font(.headline)
                    .foregroundColor(.hikingTextPrimary)
                
                Picker("Experience Level", selection: $hikerLevel) {
                    ForEach(HikerExperience.allCases, id: \.self) { level in
                        Text(level.rawValue).tag(level)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            .padding()
            .background(Color.hikingBackground.opacity(0.5))
            .cornerRadius(12)
        }
    }
    
    private var dateSelectionStep: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Select Date")
                .font(.title2)
                .foregroundColor(.hikingTextPrimary)
            
            DatePicker(
                "Planned Date",
                selection: $plannedDate,
                displayedComponents: [.date]
            )
            .datePickerStyle(GraphicalDatePickerStyle())
            .accentColor(.hikingAccent1)
            .padding()
            .background(Color.hikingBackground.opacity(0.5))
            .cornerRadius(12)
            
            if let route = selectedRoute {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Estimated Time")
                        .font(.headline)
                        .foregroundColor(.hikingTextPrimary)
                    
                    let estimatedTime = RouteCalculator.calculateHikeTime(route: route, hikerLevel: hikerLevel)
                    Text(formatTime(estimatedTime))
                        .font(.title3)
                        .foregroundColor(.hikingAccent1)
                }
                .padding()
                .background(Color.hikingBackground.opacity(0.5))
                .cornerRadius(12)
            }
        }
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = (Int(time) % 3600) / 60
        return "\(hours)h \(minutes)m"
    }
    
    private func createPlan() {
        guard let route = selectedRoute else { return }
        planViewModel.createPlan(
            for: route,
            groupSize: groupSize,
            hikerLevel: hikerLevel,
            plannedDate: plannedDate
        )
        dismiss()
    }
}

struct RouteSelectionCard: View {
    let route: HikingRoute
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(route.name)
                        .font(.headline)
                        .foregroundColor(.hikingTextPrimary)
                    Text("\(String(format: "%.1f", route.totalDistance)) km • \(route.difficulty.rawValue)")
                        .font(.caption)
                        .foregroundColor(.hikingTextSecondary)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.hikingAccent1)
                }
            }
            .padding()
            .background(isSelected ? Color.hikingAccent1.opacity(0.2) : Color.hikingBackground.opacity(0.5))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.hikingAccent1 : Color.clear, lineWidth: 2)
            )
        }
    }
}

