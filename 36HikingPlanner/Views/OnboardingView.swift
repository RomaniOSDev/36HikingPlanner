//
//  OnboardingView.swift
//  36HikingPlanner
//
//  Created by Роман Главацкий on 24.12.2025.
//

import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var currentPage = 0
    
    var body: some View {
        ZStack {
            Color.hikingBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Page Content
                TabView(selection: $currentPage) {
                    OnboardingPage(
                        image: "map.fill",
                        title: "Plan Your Routes",
                        description: "Create and manage your hiking routes with detailed waypoints, elevation profiles, and difficulty levels.",
                        color: .hikingAccent1
                    )
                    .tag(0)
                    
                    OnboardingPage(
                        image: "checklist",
                        title: "Track Equipment",
                        description: "Keep track of your gear with comprehensive checklists. Never forget essential items for your adventure.",
                        color: .hikingGold
                    )
                    .tag(1)
                    
                    OnboardingPage(
                        image: "cloud.sun.fill",
                        title: "Stay Safe",
                        description: "Get weather forecasts, safety warnings, and emergency preparation tips for your hiking trips.",
                        color: .hikingWater
                    )
                    .tag(2)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
                
                // Bottom Button
                VStack(spacing: 16) {
                    if currentPage == 2 {
                        Button(action: {
                            hasCompletedOnboarding = true
                        }) {
                            Text("Get Started")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.hikingAccent1)
                                .cornerRadius(12)
                        }
                        .padding(.horizontal)
                    } else {
                        Button(action: {
                            withAnimation {
                                currentPage += 1
                            }
                        }) {
                            Text("Next")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.hikingAccent1)
                                .cornerRadius(12)
                        }
                        .padding(.horizontal)
                        
                        Button(action: {
                            hasCompletedOnboarding = true
                        }) {
                            Text("Skip")
                                .font(.subheadline)
                                .foregroundColor(.hikingTextSecondary)
                        }
                    }
                }
                .padding(.bottom, 40)
            }
        }
        .preferredColorScheme(.dark)
    }
}

struct OnboardingPage: View {
    let image: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Icon
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 200, height: 200)
                
                Image(systemName: image)
                    .font(.system(size: 80))
                    .foregroundColor(color)
            }
            
            // Text Content
            VStack(spacing: 16) {
                Text(title)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.hikingTextPrimary)
                    .multilineTextAlignment(.center)
                
                Text(description)
                    .font(.body)
                    .foregroundColor(.hikingTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Spacer()
        }
        .padding()
    }
}

