//
//  FeedFragranceCard.swift
//  Scentdex
//
//  Created by macbook on 18/05/2026.
//

import SwiftUI

struct FeedFragranceCard: View {
    
    let fragrance: FeedFragrance
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            
            // Image
            Group {
                if let imageUrl = fragrance.imageUrl,
                   let url = URL(string: imageUrl) {
                    AsyncImage(url: url) {phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill )
                            
                        default:
                            placeholderView
                        }
                    }
                } else {
                    placeholderView
                }
            }
            .frame(height: 120)
            .clipped()
            
            VStack(alignment: .leading, spacing: 4) {
                Text(fragrance.name)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                
                Text(fragrance.brand)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                
                Text(fragrance.family.capitalized)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(familyColor.opacity(0.2))
                    .foregroundStyle(familyColor)
                    .clipShape(Capsule())
            }
            .padding(10)
        }
        .frame(width: 140)
        .background(Color(.systemGray6).opacity(0.3))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
    
    private var placeholderView: some View {
        ZStack{
            familyColor.opacity(0.15)
            Image(systemName: "Flask")
                .font(.system(size: 28))
                .foregroundStyle(familyColor.opacity(0.5))
            
        }
    }
    private var familyColor: Color {
        FragranceFamily(rawValue: fragrance.family.capitalized)?.color ?? .gray
        }
    }
