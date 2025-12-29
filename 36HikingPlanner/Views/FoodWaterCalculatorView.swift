//
//  FoodWaterCalculatorView.swift
//  36HikingPlanner
//
//  Created by Роман Главацкий on 24.12.2025.
//

import SwiftUI

struct FoodWaterCalculatorView: View {
    @ObservedObject var planViewModel: PlanViewModel
    let plan: HikePlan
    
    @State private var waterPerPerson: Double
    @State private var caloriesPerPerson: Int
    
    init(planViewModel: PlanViewModel, plan: HikePlan) {
        self.planViewModel = planViewModel
        self.plan = plan
        _waterPerPerson = State(initialValue: plan.foodWaterPlan.waterPerPerson)
        _caloriesPerPerson = State(initialValue: plan.foodWaterPlan.caloriesPerPerson)
    }
    
    var totalWater: Double {
        waterPerPerson * Double(plan.groupSize)
    }
    
    var totalWeight: Double {
        let waterWeight = totalWater * 1.0 // 1L = 1kg
        let foodWeight = Double(caloriesPerPerson * plan.groupSize) / 1000.0 * 0.5
        return waterWeight + foodWeight
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Water Section
                    waterSection
                    
                    // Calories Section
                    caloriesSection
                    
                    // Summary
                    summarySection
                    
                    // Meals
                    mealsSection
                }
                .padding()
            }
            .background(Color.hikingBackground)
            .navigationTitle("Food & Water")
            .navigationBarTitleDisplayMode(.large)
            .preferredColorScheme(.dark)
        }
    }
    
    private var waterSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Water Requirements")
                .font(.headline)
                .foregroundColor(.hikingTextPrimary)
            
            VStack(spacing: 16) {
                HStack {
                    Text("Per Person")
                        .foregroundColor(.hikingTextSecondary)
                    Spacer()
                    Text("\(String(format: "%.1f", waterPerPerson)) L")
                        .foregroundColor(.hikingTextPrimary)
                        .font(.title3)
                }
                
                Slider(value: $waterPerPerson, in: 0.5...5.0, step: 0.5)
                    .accentColor(.hikingWater)
                
                HStack {
                    Text("Total for Group")
                        .foregroundColor(.hikingTextSecondary)
                    Spacer()
                    Text("\(String(format: "%.1f", totalWater)) L")
                        .foregroundColor(.hikingWater)
                        .font(.title2)
                }
            }
            .padding()
            .background(Color.hikingBackground.opacity(0.5))
            .cornerRadius(12)
        }
    }
    
    private var caloriesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Calorie Requirements")
                .font(.headline)
                .foregroundColor(.hikingTextPrimary)
            
            VStack(spacing: 16) {
                HStack {
                    Text("Per Person")
                        .foregroundColor(.hikingTextSecondary)
                    Spacer()
                    Text("\(caloriesPerPerson) kcal")
                        .foregroundColor(.hikingTextPrimary)
                        .font(.title3)
                }
                
                Slider(value: Binding(
                    get: { Double(caloriesPerPerson) },
                    set: { caloriesPerPerson = Int($0) }
                ), in: 1500...5000, step: 100)
                    .accentColor(.hikingGold)
                
                HStack {
                    Text("Total for Group")
                        .foregroundColor(.hikingTextSecondary)
                    Spacer()
                    Text("\(caloriesPerPerson * plan.groupSize) kcal")
                        .foregroundColor(.hikingGold)
                        .font(.title2)
                }
            }
            .padding()
            .background(Color.hikingBackground.opacity(0.5))
            .cornerRadius(12)
        }
    }
    
    private var summarySection: some View {
        VStack(spacing: 12) {
            Text("Total Weight")
                .font(.headline)
                .foregroundColor(.hikingTextPrimary)
            
            Text("\(String(format: "%.1f", totalWeight)) kg")
                .font(.title)
                .foregroundColor(.hikingAccent1)
            
            HStack(spacing: 20) {
                VStack {
                    Text("\(String(format: "%.1f", totalWater))")
                        .font(.title3)
                        .foregroundColor(.hikingWater)
                    Text("Water (L)")
                        .font(.caption)
                        .foregroundColor(.hikingTextSecondary)
                }
                
                VStack {
                    Text("\(String(format: "%.1f", totalWeight - totalWater))")
                        .font(.title3)
                        .foregroundColor(.hikingGold)
                    Text("Food (kg)")
                        .font(.caption)
                        .foregroundColor(.hikingTextSecondary)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.hikingBackground.opacity(0.5))
        .cornerRadius(12)
    }
    
    private var mealsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Meals")
                .font(.headline)
                .foregroundColor(.hikingTextPrimary)
            
            if plan.foodWaterPlan.meals.isEmpty {
                Text("No meals planned yet")
                    .foregroundColor(.hikingTextSecondary)
                    .padding()
            } else {
                ForEach(plan.foodWaterPlan.meals) { meal in
                    MealRow(meal: meal)
                }
            }
        }
        .padding()
        .background(Color.hikingBackground.opacity(0.5))
        .cornerRadius(12)
    }
}

struct MealRow: View {
    let meal: Meal
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(meal.name)
                    .font(.headline)
                    .foregroundColor(.hikingTextPrimary)
                Text(meal.timeOfDay.rawValue)
                    .font(.caption)
                    .foregroundColor(.hikingTextSecondary)
            }
            
            Spacer()
            
            Text("\(meal.calories) kcal")
                .font(.subheadline)
                .foregroundColor(.hikingGold)
        }
        .padding(.vertical, 4)
    }
}

