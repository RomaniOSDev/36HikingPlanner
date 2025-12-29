//
//  SettingsView.swift
//  36HikingPlanner
//
//  Created by Роман Главацкий on 24.12.2025.
//

import SwiftUI
import StoreKit

struct SettingsView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("About")) {
                    SettingsRow(
                        icon: "star.fill",
                        iconColor: .hikingGold,
                        title: "Rate Us",
                        action: {
                            rateApp()
                        }
                    )
                    
                    SettingsRow(
                        icon: "lock.shield.fill",
                        iconColor: .hikingAccent1,
                        title: "Privacy Policy",
                        action: {
                            openPrivacyPolicy()
                        }
                    )
                    
                    SettingsRow(
                        icon: "doc.text.fill",
                        iconColor: .hikingWater,
                        title: "Terms of Service",
                        action: {
                            openTermsOfService()
                        }
                    )
                }
                
                Section(header: Text("App")) {
                    SettingsRow(
                        icon: "arrow.clockwise",
                        iconColor: .hikingTextSecondary,
                        title: "Show Onboarding",
                        action: {
                            hasCompletedOnboarding = false
                        }
                    )
                    
                    HStack {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(.hikingTextSecondary)
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.hikingTextSecondary)
                    }
                }
            }
            .background(Color.hikingBackground)
            .scrollContentBackground(.hidden)
            .navigationTitle("Settings")
            .preferredColorScheme(.dark)
        }
    }
    
    private func rateApp() {
        // App Store URL - replace with your actual app ID
        SKStoreReviewController.requestReview()
    }
    
    private func openURL(_ urlString: String) {
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
    
    private func openPrivacyPolicy() {
        if let url = URL(string: "https://www.termsfeed.com/live/74740c8d-f5f7-49fe-bc8b-968c5cceb60a") {
            UIApplication.shared.open(url)
        }
    }
    
    private func openTermsOfService() {
        if let url = URL(string: "https://www.termsfeed.com/live/4fab682e-4f35-4e50-b6df-5f4800259261") {
            UIApplication.shared.open(url)
        }
    }
}

struct SettingsRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(iconColor)
                    .frame(width: 24)
                Text(title)
                    .foregroundColor(.hikingTextPrimary)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.hikingTextSecondary)
            }
        }
    }
}

