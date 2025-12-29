//
//  MainDashboardView.swift
//  36HikingPlanner
//
//  Created by Роман Главацкий on 24.12.2025.
//

import SwiftUI

struct MainDashboardView: View {
    @ObservedObject var routeViewModel: RouteViewModel
    @ObservedObject var planViewModel: PlanViewModel
    @ObservedObject var weatherViewModel: WeatherViewModel
    @Binding var selectedTab: Int
    @State private var showingNewPlan = false
    
    var upcomingPlans: [HikePlan] {
        planViewModel.plans.filter { $0.plannedDate >= Date() }
            .sorted { $0.plannedDate < $1.plannedDate }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Quick Actions
                    quickActionsSection
                    
                    // Saved Routes
                    savedRoutesSection
                    
                    // Upcoming Hikes
                    upcomingHikesSection
                    
                    // Weather Warnings
                    weatherWarningsSection
                }
                .padding()
            }
            .background(Color.hikingBackground)
            .navigationTitle("Hiking Planner")
            .navigationBarTitleDisplayMode(.large)
            .preferredColorScheme(.dark)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingNewPlan = true }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.hikingAccent1)
                    }
                }
            }
            .sheet(isPresented: $showingNewPlan) {
                PlanCreatorView(routeViewModel: routeViewModel, planViewModel: planViewModel)
                    .preferredColorScheme(.dark)
            }
        }
    }
    
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Actions")
                .font(.headline)
                .foregroundColor(.hikingTextPrimary)
            
            HStack(spacing: 12) {
                QuickActionCard(
                    icon: "map.fill",
                    title: "Routes",
                    color: .hikingAccent1
                ) {
                    selectedTab = 1 // Routes tab
                }
                
                QuickActionCard(
                    icon: "checklist",
                    title: "Equipment",
                    color: .hikingGold
                ) {
                    selectedTab = 2 // Equipment tab
                }
                
                QuickActionCard(
                    icon: "cloud.sun.fill",
                    title: "Weather",
                    color: .hikingWater
                ) {
                    // Show weather for first upcoming plan or create new plan
                    if let firstPlan = upcomingPlans.first {
                        // Could navigate to weather view, but for now just show alert or navigate
                        selectedTab = 3 // Plans tab to see weather there
                    } else {
                        showingNewPlan = true
                    }
                }
            }
        }
    }
    
    private var savedRoutesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Saved Routes")
                .font(.headline)
                .foregroundColor(.hikingTextPrimary)
            
            if routeViewModel.routes.isEmpty {
                Text("No routes yet. Create your first route!")
                    .foregroundColor(.hikingTextSecondary)
                    .padding()
            } else {
                ForEach(routeViewModel.routes.prefix(3)) { route in
                    Button(action: {
                        selectedTab = 1 // Navigate to Routes tab
                    }) {
                        RouteCard(route: route)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
    
    private var upcomingHikesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Upcoming Hikes")
                .font(.headline)
                .foregroundColor(.hikingTextPrimary)
            
            if upcomingPlans.isEmpty {
                Text("No upcoming hikes planned")
                    .foregroundColor(.hikingTextSecondary)
                    .padding()
            } else {
                ForEach(upcomingPlans.prefix(3)) { plan in
                    if let route = planViewModel.getRoute(for: plan) {
                        Button(action: {
                            selectedTab = 3 // Navigate to Plans tab
                        }) {
                            PlanCard(plan: plan, route: route)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
        }
    }
    
    private var weatherWarningsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Weather Warnings")
                .font(.headline)
                .foregroundColor(.hikingTextPrimary)
            
            if weatherViewModel.safetyWarnings.isEmpty {
                Text("No weather warnings")
                    .foregroundColor(.hikingTextSecondary)
                    .padding()
            } else {
                ForEach(weatherViewModel.safetyWarnings.prefix(3)) { warning in
                    WarningCard(warning: warning)
                }
            }
        }
    }
}

struct QuickActionCard: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                Text(title)
                    .font(.caption)
                    .foregroundColor(.hikingTextPrimary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.hikingBackground.opacity(0.5))
            .cornerRadius(12)
        }
    }
}

struct RouteCard: View {
    let route: HikingRoute
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with name and difficulty badge
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(route.name)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.hikingTextPrimary)
                    
                    if !route.description.isEmpty {
                        Text(route.description)
                            .font(.subheadline)
                            .foregroundColor(.hikingTextSecondary)
                            .lineLimit(2)
                    }
                }
                
                Spacer()
                
                // Difficulty badge
                VStack(spacing: 4) {
                    ZStack {
                        Circle()
                            .fill(route.difficultyColor.opacity(0.2))
                            .frame(width: 40, height: 40)
                        Circle()
                            .fill(route.difficultyColor)
                            .frame(width: 12, height: 12)
                    }
                    Text(route.difficulty.rawValue)
                        .font(.caption2)
                        .foregroundColor(.hikingTextSecondary)
                }
            }
            
            Divider()
                .background(Color.hikingTextSecondary.opacity(0.3))
            
            // Stats row
            HStack(spacing: 16) {
                StatBadge(
                    icon: "ruler",
                    value: "\(String(format: "%.1f", route.totalDistance)) km",
                    color: .hikingAccent1
                )
                
                StatBadge(
                    icon: "arrow.up",
                    value: "\(Int(route.elevationGain)) m",
                    color: .hikingGold
                )
                
                StatBadge(
                    icon: "clock",
                    value: formatTime(route.estimatedTime),
                    color: .hikingWater
                )
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.hikingBackground.opacity(0.7))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(route.difficultyColor.opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = (Int(time) % 3600) / 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

struct StatBadge: View {
    let icon: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(color)
            Text(value)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.hikingTextPrimary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(color.opacity(0.15))
        .cornerRadius(8)
    }
}

struct PlanCard: View {
    let plan: HikePlan
    let route: HikingRoute
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(route.name)
                    .font(.headline)
                    .foregroundColor(.hikingTextPrimary)
                Spacer()
                Text(plan.plannedDate, style: .date)
                    .font(.caption)
                    .foregroundColor(.hikingTextSecondary)
            }
            
            Text("Group: \(plan.groupSize) • Level: \(plan.hikerLevel.rawValue)")
                .font(.caption)
                .foregroundColor(.hikingTextSecondary)
        }
        .padding()
        .background(Color.hikingBackground.opacity(0.5))
        .cornerRadius(12)
    }
}

struct WarningCard: View {
    let warning: SafetyWarning
    
    var body: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(warning.severity.color)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(warning.message)
                    .font(.subheadline)
                    .foregroundColor(.hikingTextPrimary)
                Text(warning.recommendation)
                    .font(.caption)
                    .foregroundColor(.hikingTextSecondary)
            }
        }
        .padding()
        .background(warning.severity.color.opacity(0.2))
        .cornerRadius(12)
    }
}

