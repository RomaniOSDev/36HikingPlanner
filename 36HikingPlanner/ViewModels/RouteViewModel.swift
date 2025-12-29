//
//  RouteViewModel.swift
//  36HikingPlanner
//
//  Created by Роман Главацкий on 24.12.2025.
//

import Foundation
import SwiftUI
import Combine

class RouteViewModel: ObservableObject {
    @Published var routes: [HikingRoute] = []
    @Published var selectedRoute: HikingRoute?
    @Published var isLoading = false
    
    init() {
        loadSampleRoutes()
    }
    
    func loadSampleRoutes() {
        // Sample routes for MVP
        routes = [
            HikingRoute(
                id: UUID(),
                name: "Mountain Trail",
                description: "Scenic mountain trail with beautiful views",
                totalDistance: 12.5,
                estimatedTime: 14400,
                elevationGain: 800,
                elevationLoss: 200,
                difficulty: .moderate,
                season: .summer,
                waypoints: [
                    Waypoint(id: UUID(), name: "Trailhead", distanceFromStart: 0, elevation: 500, type: .start, notes: nil, estimatedTimeFromStart: 0, isWaterSource: false, isCampSite: false, dangerLevel: .none),
                    Waypoint(id: UUID(), name: "Summit", distanceFromStart: 6.25, elevation: 1300, type: .viewpoint, notes: "Great view point", estimatedTimeFromStart: 3, isWaterSource: false, isCampSite: false, dangerLevel: .low),
                    Waypoint(id: UUID(), name: "Waterfall", distanceFromStart: 10, elevation: 1100, type: .water, notes: "Fresh water source", estimatedTimeFromStart: 4.5, isWaterSource: true, isCampSite: false, dangerLevel: .none),
                    Waypoint(id: UUID(), name: "End Point", distanceFromStart: 12.5, elevation: 600, type: .end, notes: nil, estimatedTimeFromStart: 6, isWaterSource: false, isCampSite: false, dangerLevel: .none)
                ],
                createdDate: Date(),
                lastHiked: nil
            )
        ]
    }
    
    func addRoute(_ route: HikingRoute) {
        routes.append(route)
    }
    
    func updateRoute(_ route: HikingRoute) {
        if let index = routes.firstIndex(where: { $0.id == route.id }) {
            routes[index] = route
        }
    }
    
    func deleteRoute(_ route: HikingRoute) {
        routes.removeAll { $0.id == route.id }
    }
    
    func addWaypoint(to route: HikingRoute, waypoint: Waypoint) {
        if let index = routes.firstIndex(where: { $0.id == route.id }) {
            routes[index].waypoints.append(waypoint)
        }
    }
    
    func updateWaypoint(in route: HikingRoute, waypoint: Waypoint) {
        if let routeIndex = routes.firstIndex(where: { $0.id == route.id }),
           let waypointIndex = routes[routeIndex].waypoints.firstIndex(where: { $0.id == waypoint.id }) {
            routes[routeIndex].waypoints[waypointIndex] = waypoint
        }
    }
}

