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
        case .woody:     return .purple
        case .floral:    return .pink
        case .oriental:  return .orange
        case .fresh:     return .mint
        case .citrus:    return .yellow
        case .aquatic:   return .blue
        case .gourmand:  return .purple
        case .spicy:     return .red
        case .herbal:    return .green
        }
    }
}
