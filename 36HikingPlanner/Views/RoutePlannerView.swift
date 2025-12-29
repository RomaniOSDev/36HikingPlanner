//
//  RoutePlannerView.swift
//  36HikingPlanner
//
//  Created by Роман Главацкий on 24.12.2025.
//

import SwiftUI

struct RoutePlannerView: View {
    @ObservedObject var viewModel: RouteViewModel
    @State private var selectedRoute: HikingRoute?
    @State private var showingRouteDetail = false
    @State private var showingAddRoute = false
    @State private var editingRoute: HikingRoute?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    if viewModel.routes.isEmpty {
                        VStack(spacing: 20) {
                            Image(systemName: "map")
                                .font(.system(size: 60))
                                .foregroundColor(.hikingAccent1.opacity(0.5))
                            
                            Text("No Routes Yet")
                                .font(.title2)
                                .foregroundColor(.hikingTextPrimary)
                            
                            Text("Create your first hiking route to get started")
                                .font(.subheadline)
                                .foregroundColor(.hikingTextSecondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                            
                            Button(action: { showingAddRoute = true }) {
                                HStack {
                                    Image(systemName: "plus.circle.fill")
                                    Text("Create Route")
                                }
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.hikingAccent1)
                                .cornerRadius(12)
                            }
                            .padding(.top)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 50)
                    } else {
                        // Route List
                        ForEach(viewModel.routes) { route in
                            RouteDetailCard(route: route)
                                .onTapGesture {
                                    selectedRoute = route
                                    showingRouteDetail = true
                                }
                                .contextMenu {
                                    Button(action: {
                                        editingRoute = route
                                    }) {
                                        Label("Edit", systemImage: "pencil")
                                    }
                                    
                                    Button(role: .destructive, action: {
                                        viewModel.deleteRoute(route)
                                    }) {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                        }
                    }
                }
                .padding()
            }
            .background(Color.hikingBackground)
            .navigationTitle("Routes")
            .preferredColorScheme(.dark)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddRoute = true }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.hikingAccent1)
                    }
                }
            }
            .sheet(isPresented: $showingAddRoute) {
                AddEditRouteView(viewModel: viewModel)
                    .preferredColorScheme(.dark)
            }
            .sheet(item: $editingRoute) { route in
                AddEditRouteView(viewModel: viewModel, editingRoute: route)
                    .preferredColorScheme(.dark)
            }
            .sheet(item: $selectedRoute) { route in
                RouteDetailView(route: route, viewModel: viewModel)
                    .preferredColorScheme(.dark)
            }
        }
    }
}

struct RouteDetailCard: View {
    let route: HikingRoute
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header with name and difficulty badge
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(route.name)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.hikingTextPrimary)
                    
                    if !route.description.isEmpty {
                        Text(route.description)
                            .font(.subheadline)
                            .foregroundColor(.hikingTextSecondary)
                            .lineLimit(3)
                    }
                }
                
                Spacer()
                
                // Difficulty badge
                VStack(spacing: 6) {
                    ZStack {
                        Circle()
                            .fill(route.difficultyColor.opacity(0.2))
                            .frame(width: 50, height: 50)
                        Circle()
                            .fill(route.difficultyColor)
                            .frame(width: 16, height: 16)
                    }
                    Text(route.difficulty.rawValue)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.hikingTextSecondary)
                }
            }
            
            Divider()
                .background(Color.hikingTextSecondary.opacity(0.3))
            
            // Stats row with better visual hierarchy
            HStack(spacing: 12) {
                StatView(icon: "ruler", value: "\(String(format: "%.1f", route.totalDistance)) km", color: .hikingAccent1)
                StatView(icon: "arrow.up", value: "\(Int(route.elevationGain)) m", color: .hikingGold)
                StatView(icon: "clock", value: formatTime(route.estimatedTime), color: .hikingWater)
            }
            
            // Elevation Profile (simplified)
            ElevationProfileView(route: route)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.hikingBackground.opacity(0.7))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(route.difficultyColor.opacity(0.3), lineWidth: 1.5)
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

struct StatView: View {
    let icon: String
    let value: String
    let color: Color
    
    init(icon: String, value: String, color: Color = .hikingAccent1) {
        self.icon = icon
        self.value = value
        self.color = color
    }
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(color)
            Text(value)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.hikingTextPrimary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(color.opacity(0.15))
        .cornerRadius(10)
    }
}

struct ElevationProfileView: View {
    let route: HikingRoute
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Elevation Profile")
                .font(.caption)
                .foregroundColor(.hikingTextSecondary)
            
            GeometryReader { geometry in
                Path { path in
                    let width = geometry.size.width
                    let height = geometry.size.height
                    let maxElevation = route.waypoints.map { $0.elevation }.max() ?? 1000
                    let minElevation = route.waypoints.map { $0.elevation }.min() ?? 0
                    let elevationRange = maxElevation - minElevation
                    
                    if !route.waypoints.isEmpty {
                        path.move(to: CGPoint(x: 0, y: height))
                        
                        for (index, waypoint) in route.waypoints.enumerated() {
                            let x = CGFloat(index) / CGFloat(max(route.waypoints.count - 1, 1)) * width
                            let normalizedElevation = (waypoint.elevation - minElevation) / max(elevationRange, 1)
                            let y = height - (normalizedElevation * height)
                            path.addLine(to: CGPoint(x: x, y: y))
                        }
                    }
                }
                .stroke(Color.hikingAccent1, lineWidth: 2)
            }
            .frame(height: 100)
            .background(Color.hikingBackground.opacity(0.3))
            .cornerRadius(8)
        }
    }
}

struct RouteDetailView: View {
    let route: HikingRoute
    @ObservedObject var viewModel: RouteViewModel
    @Environment(\.dismiss) var dismiss
    @State private var showingEditRoute = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Route Info
                    VStack(alignment: .leading, spacing: 12) {
                        Text(route.name)
                            .font(.title)
                            .foregroundColor(.hikingTextPrimary)
                        
                        Text(route.description)
                            .foregroundColor(.hikingTextSecondary)
                        
                        // Route Stats
                        HStack(spacing: 16) {
                            VStack {
                                Text("\(String(format: "%.1f", route.totalDistance))")
                                    .font(.title2)
                                    .foregroundColor(.hikingTextPrimary)
                                Text("Distance")
                                    .font(.caption)
                                    .foregroundColor(.hikingTextSecondary)
                            }
                            
                            VStack {
                                Text("\(Int(route.elevationGain))")
                                    .font(.title2)
                                    .foregroundColor(.hikingTextPrimary)
                                Text("Elevation Gain")
                                    .font(.caption)
                                    .foregroundColor(.hikingTextSecondary)
                            }
                            
                            VStack {
                                Text("\(String(format: "%.1f", route.averageGrade))%")
                                    .font(.title2)
                                    .foregroundColor(.hikingTextPrimary)
                                Text("Average Grade")
                                    .font(.caption)
                                    .foregroundColor(.hikingTextSecondary)
                            }
                        }
                    }
                    .padding()
                    .background(Color.hikingBackground.opacity(0.5))
                    .cornerRadius(16)
                    
                    // Waypoints
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Waypoints")
                            .font(.headline)
                            .foregroundColor(.hikingTextPrimary)
                        
                        ForEach(route.waypoints) { waypoint in
                            WaypointRow(waypoint: waypoint)
                        }
                    }
                    .padding()
                    .background(Color.hikingBackground.opacity(0.5))
                    .cornerRadius(16)
                }
                .padding()
            }
            .background(Color.hikingBackground)
            .navigationTitle("Route Details")
            .navigationBarTitleDisplayMode(.inline)
            .preferredColorScheme(.dark)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Edit") {
                        showingEditRoute = true
                    }
                    .foregroundColor(.hikingAccent1)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.hikingAccent1)
                }
            }
            .sheet(isPresented: $showingEditRoute) {
                AddEditRouteView(viewModel: viewModel, editingRoute: route)
                    .preferredColorScheme(.dark)
            }
        }
    }
}

struct WaypointRow: View {
    let waypoint: Waypoint
    
    var body: some View {
        HStack {
            Circle()
                .fill(waypoint.color)
                .frame(width: 12, height: 12)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(waypoint.name)
                    .font(.subheadline)
                    .foregroundColor(.hikingTextPrimary)
                Text("\(String(format: "%.1f", waypoint.distanceFromStart)) km • \(Int(waypoint.elevation)) m")
                    .font(.caption)
                    .foregroundColor(.hikingTextSecondary)
            }
            
            Spacer()
            
            if waypoint.dangerLevel != .none {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(waypoint.dangerLevel.color)
            }
        }
        .padding(.vertical, 4)
    }
}

