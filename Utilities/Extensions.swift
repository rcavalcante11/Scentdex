//
//  Extensions.swift
//  Scentdex
//
//  Created by macbook on 28/04/2026.
//
import SwiftUI

extension Color {
    init?(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8) & 0xFF) / 255
        let b = Double(int & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}

extension FragranceFamily {
    var color: Color {
        switch self {
            case .woody:     return Color(hex: "#8B5E3C") ?? .brown
            case .floral:    return Color(hex: "#E8A0BF") ?? .pink
            case .oriental:  return Color(hex: "#C9A84C") ?? .orange
            case .fresh:     return .mint
            case .citrus:    return Color(hex: "#F4A320") ?? .yellow
            case .aquatic:   return Color(hex: "#0EA5E9") ?? .blue
            case .gourmand:  return Color(hex: "#9B59B6") ?? .purple
            case .spicy:     return Color(hex: "#C0392B") ?? .red
            case .herbal:    return Color(hex: "#5D8A5E") ?? .green
        }
    }
}
