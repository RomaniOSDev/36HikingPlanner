//
//  PlanViewModel.swift
//  36HikingPlanner
//
//  Created by Роман Главацкий on 24.12.2025.
//

import Foundation
import SwiftUI
import Combine

class PlanViewModel: ObservableObject {
    @Published var plans: [HikePlan] = []
    @Published var currentPlan: HikePlan?
    @Published var isLoading = false
    
    private let routeViewModel: RouteViewModel
    
    init(routeViewModel: RouteViewModel) {
        self.routeViewModel = routeViewModel
    }
    
    func loadSamplePlansIfNeeded() {
        // Create sample plans if routes exist and no plans yet
        guard !routeViewModel.routes.isEmpty, plans.isEmpty else { return }
        
        let sampleRoute = routeViewModel.routes[0]
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
        
        // Create sample plan for tomorrow
        createPlan(
            for: sampleRoute,
            groupSize: 2,
            hikerLevel: .intermediate,
            plannedDate: tomorrow
        )
    }
    
    func createPlan(for route: HikingRoute, groupSize: Int, hikerLevel: HikerExperience, plannedDate: Date) {
        let estimatedTime = RouteCalculator.calculateHikeTime(route: route, hikerLevel: hikerLevel)
        
        // Create time slots
        let startTime = Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: plannedDate) ?? plannedDate
        var timeSlots: [TimeSlot] = []
        
        // Add hiking time slots
        let hikingDuration = estimatedTime * 0.8 // 80% hiking
        let restDuration = estimatedTime * 0.2 // 20% rest
        
        timeSlots.append(TimeSlot(
            id: UUID(),
            activity: .hiking,
            startTime: startTime,
            duration: hikingDuration,
            distanceCovered: route.totalDistance,
            notes: nil
        ))
        
        // Add rest slot
        if let hikingEnd = timeSlots.first?.endTime {
            timeSlots.append(TimeSlot(
                id: UUID(),
                activity: .rest,
                startTime: hikingEnd,
                duration: restDuration,
                distanceCovered: nil,
                notes: nil
            ))
        }
        
        // Create food/water plan
        let temperature = 20.0 // Default temperature
        let waterPerPerson = RouteCalculator.calculateWaterNeeds(route: route, temperature: temperature, duration: estimatedTime)
        
        let foodWaterPlan = FoodWaterCalculation(
            waterPerPerson: waterPerPerson,
            caloriesPerPerson: RouteCalculator.estimateCalorieBurn(route: route, weight: 70.0),
            meals: [],
            snacks: []
        )
        
        // Get equipment template
        let equipmentChecklist = EquipmentTemplates.getTemplate(for: route.season)
        
        let plan = HikePlan(
            id: UUID(),
            routeId: route.id,
            plannedDate: plannedDate,
            groupSize: groupSize,
            hikerLevel: hikerLevel,
            weatherConditions: nil,
            timeSlots: timeSlots,
            equipmentChecklist: equipmentChecklist,
            foodWaterPlan: foodWaterPlan,
            emergencyContacts: [],
            notes: nil
        )
        
        currentPlan = plan
        plans.append(plan)
    }
    
    func updatePlan(_ plan: HikePlan) {
        if let index = plans.firstIndex(where: { $0.id == plan.id }) {
            plans[index] = plan
        }
        if currentPlan?.id == plan.id {
            currentPlan = plan
        }
    }
    
    func deletePlan(_ plan: HikePlan) {
        plans.removeAll { $0.id == plan.id }
        if currentPlan?.id == plan.id {
            currentPlan = nil
        }
    }
    
    func getRoute(for plan: HikePlan) -> HikingRoute? {
        return routeViewModel.routes.first { $0.id == plan.routeId }
    }
}

