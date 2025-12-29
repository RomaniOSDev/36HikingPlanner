//
//  ColorExtension.swift
//  36HikingPlanner
//
//  Created by Роман Главацкий on 24.12.2025.
//

import SwiftUI

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    static let hikingBackground = Color(hex: "273F1F")
    static let hikingAccent1 = Color(hex: "2FAE4D")
    static let hikingAccent2 = Color(hex: "A40D01")
    static let hikingTextPrimary = Color.white.opacity(0.95)
    static let hikingTextSecondary = Color(hex: "C8C8C8").opacity(0.8)
    static let hikingGold = Color(hex: "FFD700")
    static let hikingWater = Color(hex: "1E90FF")
    static let hikingEarth = Color(hex: "8B4513")
}

