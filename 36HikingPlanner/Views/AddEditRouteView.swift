//
//  AddEditRouteView.swift
//  36HikingPlanner
//
//  Created by Роман Главацкий on 24.12.2025.
//

import SwiftUI

struct AddEditRouteView: View {
    @ObservedObject var viewModel: RouteViewModel
    @Environment(\.dismiss) var dismiss
    
    let editingRoute: HikingRoute?
    
    @State private var name: String
    @State private var description: String
    @State private var totalDistance: String
    @State private var elevationGain: String
    @State private var elevationLoss: String
    @State private var difficulty: DifficultyLevel
    @State private var season: Season
    @State private var waypoints: [Waypoint]
    @State private var showingAddWaypoint = false
    @State private var editingWaypoint: Waypoint?
    
    init(viewModel: RouteViewModel, editingRoute: HikingRoute? = nil) {
        self.viewModel = viewModel
        self.editingRoute = editingRoute
        
        if let route = editingRoute {
            _name = State(initialValue: route.name)
            _description = State(initialValue: route.description)
            _totalDistance = State(initialValue: String(format: "%.1f", route.totalDistance))
            _elevationGain = State(initialValue: String(format: "%.0f", route.elevationGain))
            _elevationLoss = State(initialValue: String(format: "%.0f", route.elevationLoss))
            _difficulty = State(initialValue: route.difficulty)
            _season = State(initialValue: route.season)
            _waypoints = State(initialValue: route.waypoints)
        } else {
            _name = State(initialValue: "")
            _description = State(initialValue: "")
            _totalDistance = State(initialValue: "")
            _elevationGain = State(initialValue: "")
            _elevationLoss = State(initialValue: "")
            _difficulty = State(initialValue: .moderate)
            _season = State(initialValue: .summer)
            _waypoints = State(initialValue: [])
        }
    }
    
    var estimatedTime: TimeInterval {
        guard let distance = Double(totalDistance), distance > 0 else { return 0 }
        // Simple estimation: 4 km/h base pace adjusted by difficulty
        let basePace = 4.0 // km/h
        let adjustedPace = basePace / difficulty.paceMultiplier
        let hours = distance / adjustedPace
        return hours * 3600 // convert to seconds
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Basic Information")) {
                    TextField("Route Name", text: $name)
                        .foregroundColor(.hikingTextPrimary)
                    
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                        .foregroundColor(.hikingTextPrimary)
                    
                    Picker("Difficulty", selection: $difficulty) {
                        ForEach(DifficultyLevel.allCases, id: \.self) { level in
                            Text(level.rawValue).tag(level)
                        }
                    }
                    .foregroundColor(.hikingTextPrimary)
                    
                    Picker("Season", selection: $season) {
                        ForEach(Season.allCases, id: \.self) { s in
                            Text(s.rawValue).tag(s)
                        }
                    }
                    .foregroundColor(.hikingTextPrimary)
                }
                
                Section(header: Text("Route Details")) {
                    HStack {
                        Text("Distance (km)")
                        Spacer()
                        TextField("0.0", text: $totalDistance)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .foregroundColor(.hikingTextPrimary)
                    }
                    
                    HStack {
                        Text("Elevation Gain (m)")
                        Spacer()
                        TextField("0", text: $elevationGain)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .foregroundColor(.hikingTextPrimary)
                    }
                    
                    HStack {
                        Text("Elevation Loss (m)")
                        Spacer()
                        TextField("0", text: $elevationLoss)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .foregroundColor(.hikingTextPrimary)
                    }
                    
                    if estimatedTime > 0 {
                        HStack {
                            Text("Estimated Time")
                            Spacer()
                            Text(formatTime(estimatedTime))
                                .foregroundColor(.hikingAccent1)
                                .fontWeight(.semibold)
                        }
                    }
                }
                
                Section(header: HStack {
                    Text("Waypoints")
                    Spacer()
                    Button(action: { showingAddWaypoint = true }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.hikingAccent1)
                    }
                }) {
                    if waypoints.isEmpty {
                        Text("No waypoints added")
                            .foregroundColor(.hikingTextSecondary)
                            .font(.caption)
                    } else {
                        ForEach(waypoints) { waypoint in
                            WaypointEditRow(waypoint: waypoint) {
                                editingWaypoint = waypoint
                            } onDelete: {
                                waypoints.removeAll { $0.id == waypoint.id }
                            }
                        }
                    }
                }
            }
            .background(Color.hikingBackground)
            .scrollContentBackground(.hidden)
            .navigationTitle(editingRoute == nil ? "Add Route" : "Edit Route")
            .navigationBarTitleDisplayMode(.inline)
            .preferredColorScheme(.dark)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.hikingTextSecondary)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveRoute()
                    }
                    .foregroundColor(.hikingAccent1)
                    .disabled(name.isEmpty || totalDistance.isEmpty)
                }
            }
            .sheet(isPresented: $showingAddWaypoint) {
                AddEditWaypointView(
                    waypoints: $waypoints,
                    totalDistance: Double(totalDistance) ?? 0
                )
                .preferredColorScheme(.dark)
            }
            .sheet(item: $editingWaypoint) { waypoint in
                AddEditWaypointView(
                    waypoints: $waypoints,
                    totalDistance: Double(totalDistance) ?? 0,
                    editingWaypoint: waypoint
                )
                .preferredColorScheme(.dark)
            }
        }
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
    
    private func saveRoute() {
        guard let distance = Double(totalDistance),
              let gain = Double(elevationGain),
              let loss = Double(elevationLoss) else { return }
        
        // Ensure we have at least start and end waypoints
        var finalWaypoints = waypoints
        if finalWaypoints.isEmpty {
            // Add default start and end waypoints
            finalWaypoints.append(Waypoint(
                id: UUID(),
                name: "Start",
                distanceFromStart: 0,
                elevation: 0,
                type: .start,
                notes: nil,
                estimatedTimeFromStart: 0,
                isWaterSource: false,
                isCampSite: false,
                dangerLevel: .none
            ))
            finalWaypoints.append(Waypoint(
                id: UUID(),
                name: "End",
                distanceFromStart: distance,
                elevation: gain - loss,
                type: .end,
                notes: nil,
                estimatedTimeFromStart: estimatedTime / 3600,
                isWaterSource: false,
                isCampSite: false,
                dangerLevel: .none
            ))
        }
        
        let route = HikingRoute(
            id: editingRoute?.id ?? UUID(),
            name: name,
            description: description,
            totalDistance: distance,
            estimatedTime: estimatedTime,
            elevationGain: gain,
            elevationLoss: loss,
            difficulty: difficulty,
            season: season,
            waypoints: finalWaypoints.sorted { $0.distanceFromStart < $1.distanceFromStart },
            createdDate: editingRoute?.createdDate ?? Date(),
            lastHiked: editingRoute?.lastHiked
        )
        
        if let editingRoute = editingRoute {
            viewModel.updateRoute(route)
        } else {
            viewModel.addRoute(route)
        }
        
        dismiss()
    }
}

struct WaypointEditRow: View {
    let waypoint: Waypoint
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            Circle()
                .fill(waypoint.color)
                .frame(width: 12, height: 12)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(waypoint.name)
                    .font(.subheadline)
                    .foregroundColor(.hikingTextPrimary)
                Text("\(String(format: "%.1f", waypoint.distanceFromStart)) km • \(Int(waypoint.elevation)) m • \(waypoint.type.rawValue)")
                    .font(.caption)
                    .foregroundColor(.hikingTextSecondary)
            }
            
            Spacer()
            
            Menu {
                Button(action: onEdit) {
                    Label("Edit", systemImage: "pencil")
                }
                Button(role: .destructive, action: onDelete) {
                    Label("Delete", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .foregroundColor(.hikingTextSecondary)
            }
        }
    }
}

struct AddEditWaypointView: View {
    @Binding var waypoints: [Waypoint]
    let totalDistance: Double
    let editingWaypoint: Waypoint?
    @Environment(\.dismiss) var dismiss
    
    @State private var name: String
    @State private var distanceFromStart: String
    @State private var elevation: String
    @State private var type: WaypointType
    @State private var notes: String
    @State private var isWaterSource: Bool
    @State private var isCampSite: Bool
    @State private var dangerLevel: DangerLevel
    
    init(waypoints: Binding<[Waypoint]>, totalDistance: Double, editingWaypoint: Waypoint? = nil) {
        self._waypoints = waypoints
        self.totalDistance = totalDistance
        self.editingWaypoint = editingWaypoint
        
        if let waypoint = editingWaypoint {
            _name = State(initialValue: waypoint.name)
            _distanceFromStart = State(initialValue: String(format: "%.1f", waypoint.distanceFromStart))
            _elevation = State(initialValue: String(format: "%.0f", waypoint.elevation))
            _type = State(initialValue: waypoint.type)
            _notes = State(initialValue: waypoint.notes ?? "")
            _isWaterSource = State(initialValue: waypoint.isWaterSource)
            _isCampSite = State(initialValue: waypoint.isCampSite)
            _dangerLevel = State(initialValue: waypoint.dangerLevel)
        } else {
            _name = State(initialValue: "")
            _distanceFromStart = State(initialValue: "")
            _elevation = State(initialValue: "")
            _type = State(initialValue: .landmark)
            _notes = State(initialValue: "")
            _isWaterSource = State(initialValue: false)
            _isCampSite = State(initialValue: false)
            _dangerLevel = State(initialValue: .none)
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Basic Information")) {
                    TextField("Waypoint Name", text: $name)
                        .foregroundColor(.hikingTextPrimary)
                    
                    Picker("Type", selection: $type) {
                        ForEach(WaypointType.allCases, id: \.self) { t in
                            Text(t.rawValue).tag(t)
                        }
                    }
                    .foregroundColor(.hikingTextPrimary)
                }
                
                Section(header: Text("Location")) {
                    HStack {
                        Text("Distance from Start (km)")
                        Spacer()
                        TextField("0.0", text: $distanceFromStart)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .foregroundColor(.hikingTextPrimary)
                    }
                    
                    HStack {
                        Text("Elevation (m)")
                        Spacer()
                        TextField("0", text: $elevation)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .foregroundColor(.hikingTextPrimary)
                    }
                }
                
                Section(header: Text("Features")) {
                    Toggle("Water Source", isOn: $isWaterSource)
                        .tint(.hikingAccent1)
                    
                    Toggle("Campsite", isOn: $isCampSite)
                        .tint(.hikingAccent1)
                    
                    Picker("Danger Level", selection: $dangerLevel) {
                        ForEach(DangerLevel.allCases, id: \.self) { level in
                            Text(level.rawValue).tag(level)
                        }
                    }
                    .foregroundColor(.hikingTextPrimary)
                }
                
                Section(header: Text("Notes")) {
                    TextField("Additional notes (optional)", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                        .foregroundColor(.hikingTextPrimary)
                }
            }
            .background(Color.hikingBackground)
            .scrollContentBackground(.hidden)
            .navigationTitle(editingWaypoint == nil ? "Add Waypoint" : "Edit Waypoint")
            .navigationBarTitleDisplayMode(.inline)
            .preferredColorScheme(.dark)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.hikingTextSecondary)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveWaypoint()
                    }
                    .foregroundColor(.hikingAccent1)
                    .disabled(name.isEmpty || distanceFromStart.isEmpty)
                }
            }
        }
    }
    
    private func saveWaypoint() {
        guard let distance = Double(distanceFromStart),
              let elev = Double(elevation) else { return }
        
        let waypoint = Waypoint(
            id: editingWaypoint?.id ?? UUID(),
            name: name,
            distanceFromStart: distance,
            elevation: elev,
            type: type,
            notes: notes.isEmpty ? nil : notes,
            estimatedTimeFromStart: nil,
            isWaterSource: isWaterSource,
            isCampSite: isCampSite,
            dangerLevel: dangerLevel
        )
        
        if let editingWaypoint = editingWaypoint {
            if let index = waypoints.firstIndex(where: { $0.id == editingWaypoint.id }) {
                waypoints[index] = waypoint
            }
        } else {
            waypoints.append(waypoint)
        }
        
        dismiss()
    }
}

