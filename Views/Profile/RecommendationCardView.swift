//
//  RecommendationCardView.swift
//  Scentdex
//
//  Created by macbook on 20/04/2026.
//

import SwiftUI

struct RecommendationCardView: View {
    
    // MARK: - Properties
    let fragrance: FragranceResult
    
    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            // Family pull
            Text(fragrance.family.capitalized)
                .font(.caption)
                .fontWeight(.medium)
                .padding(.horizontal, 10)
                .background(familyColor.opacity(0.2))
                .foregroundStyle(familyColor)
                .clipShape(Capsule())
            
            Spacer()
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(fragrance.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .lineLimit(2)
                    .foregroundStyle(.primary)
                
                Text(fragrance.brand)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                if let gender = fragrance.gender {
                    Text(gender)
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
                
            }
        }
        
                .padding(16)
                .frame(width: 160, height: 200)
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
    }
    // MARK: - Helpers
       private var familyColor: Color {
           switch fragrance.family.lowercased() {
           case "woody":    return .purple
           case "floral":   return .pink
           case "oriental": return .orange
           case "fresh":    return .mint
           case "citrus":   return .yellow
           case "aquatic":  return .blue
           case "gourmand": return .purple
           case "spicy":    return .red
           case "herbal":   return .green
           default:         return .gray
           }
       }
    
    
    
    
    
    
    
    
}
