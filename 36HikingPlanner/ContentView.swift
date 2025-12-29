//
//  ContentView.swift
//  36HikingPlanner
//
//  Created by Роман Главацкий on 24.12.2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var routeViewModel = RouteViewModel()
    @StateObject private var planViewModel: PlanViewModel
    @StateObject private var equipmentViewModel = EquipmentViewModel()
    @StateObject private var weatherViewModel = WeatherViewModel()
    
    @State private var selectedTab = 0
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    
    init() {
        let routeVM = RouteViewModel()
        _routeViewModel = StateObject(wrappedValue: routeVM)
        _planViewModel = StateObject(wrappedValue: PlanViewModel(routeViewModel: routeVM))
    }
    
    var body: some View {
        Group {
            if hasCompletedOnboarding {
                TabView(selection: $selectedTab) {
                    MainDashboardView(
                        routeViewModel: routeViewModel,
                        planViewModel: planViewModel,
                        weatherViewModel: weatherViewModel,
                        selectedTab: $selectedTab
                    )
                    .tabItem {
                        Label("Dashboard", systemImage: "house.fill")
                    }
                    .tag(0)
                    
                    RoutePlannerView(viewModel: routeViewModel)
                        .tabItem {
                            Label("Routes", systemImage: "map.fill")
                        }
                        .tag(1)
                    
                    EquipmentChecklistView(viewModel: equipmentViewModel)
                        .tabItem {
                            Label("Equipment", systemImage: "checklist")
                        }
                        .tag(2)
                    
                    PlansListView(
                        planViewModel: planViewModel,
                        routeViewModel: routeViewModel,
                        weatherViewModel: weatherViewModel
                    )
                    .tabItem {
                        Label("Plans", systemImage: "calendar")
                    }
                    .tag(3)
                    
                    SettingsView()
                        .tabItem {
                            Label("Settings", systemImage: "gearshape.fill")
                        }
                        .tag(4)
                }
                .accentColor(.hikingAccent1)
                .preferredColorScheme(.dark)
                .onAppear {
                    // Load equipment for default season
                    equipmentViewModel.loadEquipment(for: .summer)
                    // Load sample plans if needed
                    planViewModel.loadSamplePlansIfNeeded()
                }
            } else {
                OnboardingView()
            }
        }
    }
}

struct PlansListView: View {
    @ObservedObject var planViewModel: PlanViewModel
    @ObservedObject var routeViewModel: RouteViewModel
    @ObservedObject var weatherViewModel: WeatherViewModel
    @State private var showingNewPlan = false
    
    var body: some View {
        NavigationView {
            Group {
                if planViewModel.plans.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "calendar.badge.plus")
                            .font(.system(size: 60))
                            .foregroundColor(.hikingAccent1.opacity(0.5))
                        
                        Text("No Plans Yet")
                            .font(.title2)
                            .foregroundColor(.hikingTextPrimary)
                        
                        Text("Create your first hiking plan to get started")
                            .font(.subheadline)
                            .foregroundColor(.hikingTextSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Button(action: { showingNewPlan = true }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("Create Plan")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.hikingAccent1)
                            .cornerRadius(12)
                        }
                        .padding(.top)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.hikingBackground)
                } else {
                    List {
                        ForEach(planViewModel.plans) { plan in
                            NavigationLink(destination: PlanDetailView(
                                plan: plan,
                                planViewModel: planViewModel,
                                routeViewModel: routeViewModel,
                                weatherViewModel: weatherViewModel
                            )) {
                                PlanListRow(plan: plan, routeViewModel: routeViewModel)
                            }
                        }
                        .onDelete { indexSet in
                            for index in indexSet {
                                planViewModel.deletePlan(planViewModel.plans[index])
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .background(Color.hikingBackground)
            .navigationTitle("Hike Plans")
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
}

struct PlanListRow: View {
    let plan: HikePlan
    @ObservedObject var routeViewModel: RouteViewModel
    
    var route: HikingRoute? {
        routeViewModel.routes.first { $0.id == plan.routeId }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(route?.name ?? "Unknown Route")
                .font(.headline)
                .foregroundColor(.hikingTextPrimary)
            
            HStack {
                Text(plan.plannedDate, style: .date)
                    .font(.subheadline)
                    .foregroundColor(.hikingTextSecondary)
                
                Spacer()
                
                Text("\(plan.groupSize) people")
                    .font(.caption)
                    .foregroundColor(.hikingTextSecondary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct PlanDetailView: View {
    let plan: HikePlan
    @ObservedObject var planViewModel: PlanViewModel
    @ObservedObject var routeViewModel: RouteViewModel
    @ObservedObject var weatherViewModel: WeatherViewModel
    @StateObject private var equipmentViewModel = EquipmentViewModel()
    
    var route: HikingRoute? {
        routeViewModel.routes.first { $0.id == plan.routeId }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if let route = route {
                    NavigationLink(destination: RouteDetailView(route: route, viewModel: routeViewModel)) {
                        RouteInfoCard(route: route)
                    }
                }
                
                NavigationLink(destination: EquipmentChecklistView(viewModel: equipmentViewModel)) {
                    EquipmentPreviewCard(equipmentCount: plan.equipmentChecklist.count)
                }
                
                NavigationLink(destination: FoodWaterCalculatorView(planViewModel: planViewModel, plan: plan)) {
                    FoodWaterPreviewCard(plan: plan)
                }
                
                NavigationLink(destination: WeatherSafetyView(viewModel: weatherViewModel, plan: plan)) {
                    WeatherPreviewCard()
                }
                
                NavigationLink(destination: EmergencyPrepView(planViewModel: planViewModel, plan: plan)) {
                    EmergencyPreviewCard()
                }
            }
            .padding()
        }
        .background(Color.hikingBackground)
        .navigationTitle("Plan Details")
        .navigationBarTitleDisplayMode(.large)
        .preferredColorScheme(.dark)
        .onAppear {
            if let route = route {
                weatherViewModel.analyzeSafety(route: route, plan: plan)
                equipmentViewModel.equipmentItems = plan.equipmentChecklist
                equipmentViewModel.calculateTotalWeight()
            }
        }
    }
}

struct RouteInfoCard: View {
    let route: HikingRoute
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Route")
                    .font(.caption)
                    .foregroundColor(.hikingTextSecondary)
                Text(route.name)
                    .font(.headline)
                    .foregroundColor(.hikingTextPrimary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.hikingTextSecondary)
        }
        .padding()
        .background(Color.hikingBackground.opacity(0.5))
        .cornerRadius(12)
    }
}

struct EquipmentPreviewCard: View {
    let equipmentCount: Int
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Equipment")
                    .font(.caption)
                    .foregroundColor(.hikingTextSecondary)
                Text("\(equipmentCount) items")
                    .font(.headline)
                    .foregroundColor(.hikingTextPrimary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.hikingTextSecondary)
        }
        .padding()
        .background(Color.hikingBackground.opacity(0.5))
        .cornerRadius(12)
    }
}

struct FoodWaterPreviewCard: View {
    let plan: HikePlan
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Food & Water")
                    .font(.caption)
                    .foregroundColor(.hikingTextSecondary)
                Text("\(String(format: "%.1f", plan.foodWaterPlan.totalWater))L water")
                    .font(.headline)
                    .foregroundColor(.hikingTextPrimary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.hikingTextSecondary)
        }
        .padding()
        .background(Color.hikingBackground.opacity(0.5))
        .cornerRadius(12)
    }
}

struct WeatherPreviewCard: View {
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Weather & Safety")
                    .font(.caption)
                    .foregroundColor(.hikingTextSecondary)
                Text("View forecast")
                    .font(.headline)
                    .foregroundColor(.hikingTextPrimary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.hikingTextSecondary)
        }
        .padding()
        .background(Color.hikingBackground.opacity(0.5))
        .cornerRadius(12)
    }
}

struct EmergencyPreviewCard: View {
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Emergency Prep")
                    .font(.caption)
                    .foregroundColor(.hikingTextSecondary)
                Text("Contacts & Checklist")
                    .font(.headline)
                    .foregroundColor(.hikingTextPrimary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.hikingTextSecondary)
        }
        .padding()
        .background(Color.hikingBackground.opacity(0.5))
        .cornerRadius(12)
    }
}

#Preview {
    ContentView()
}
