//
//  ScentAuraView.swift
//  Scentdex
//
//  Created by macbook on 30/03/2026.
//

import SwiftUI

struct ScentAuraView: View {
    
    
    // MARK: - Properties
    let profile: ScentProfile
    @State private var animate = false
    
    // MARK: - Body
    var body: some View{
        ScrollView {
            VStack(spacing: 0) {
                auraVisual
                    .frame(height: 420)
                
                profileInfo
                    .padding(24)
            }
        }
        .ignoresSafeArea(edges: .top)
        .onAppear{animate = true }
    }
    
    // MARK: - Subviews
    private var auraVisual: some View {
        ZStack {
            Color .black
            
            blobsLayer
            
            overLayGradient
            
            textOverlay
        }
        .clipShape(RoundedRectangle(cornerRadius: 0))
        
    }
    
    private var blobsLayer: some View {
        ZStack {
            ForEach(Array(blobConfigs.enumerated()), id: \.offset ) {index, config in
                Circle()
                    .fill(config.color)
                    .frame(width: config.size, height: config.size)
                    .blur(radius: 50)
                    .blendMode(.screen)
                    .offset(
                        x: animate ? config.toX : config.fromX,
                        y: animate ? config.toY : config.fromY
                    )
                    .scaleEffect(animate ? config.toScale : 1.0 )
                    .animation(
                        .easeInOut(duration: 1.5)
                        .repeatForever(autoreverses: true)
                        .delay(config.delay),
                        value: animate
                    )
            }
        }
    }
    private var overLayGradient: some View {
        LinearGradient(
            colors: [.clear, .black.opacity(0.8)],
            startPoint: .center,
            endPoint: .bottom
        )
    }
    private var textOverlay: some View {
        VStack(alignment: .leading, spacing: 8) {
            Spacer()
            Text("Your Scent Aura")
                .font(.caption)
                .fontWeight(.medium)
                .tracking(3)
                .foregroundStyle(.white.opacity(0.5))
            
            Text(profile.profileTitle)
                .font(.system(size: 34, weight: .medium))
                .foregroundStyle(.white)
            
            HStack(spacing: 8 ) {
                ForEach(topFamilies, id: \.self) { family in
                    familyTag(family)
                }
            }
            
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(28)
    }
    
    private var profileInfo: some View {
        VStack(alignment: .leading, spacing: 24) {
            
            Text(profile.profileDescription)
                .font(.body)
                .foregroundStyle(.secondary)
                .lineSpacing(6)
            
            if !profile.topNotes.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Your signature notes")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    HStack(spacing: 8 ) {
                        ForEach(profile.topNotes, id: \.self) { note in
                            Text(note)
                                .font(.caption)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background( .secondary.opacity(0.15))
                                .clipShape(Capsule())
                            
                            
                            
                        }
                    }
                }
            }
            
            familyDistributionSection
            RecommendationCarouselView(
                        profile: profile,
                        ownedPerfumes: [] // vamos passar os dados reais a seguir
                    )
        }
    }
    
    private var familyDistributionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Collection breakdown")
                .font(.subheadline)
                .fontWeight(.semibold)
            
            ForEach(sortedFamilies, id: \.key) { family, count in
                HStack {
                    Text(family.rawValue)
                        .font(.caption)
                        .frame(width: 80, alignment: .leading)
                    
                    GeometryReader { geo in
                        RoundedRectangle(cornerRadius: 4)
                            .fill(familyColor(family).opacity(0.7))
                            .frame(
                                width: geo.size.width * barWidth(for: count),
                                height: 8
                            )
                        
                    }
                    .frame(height: 8)
                    
                    Text("\(count)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                
                    }
                }
            }
        }
    
    
    
    // MARK: - Helpers
    
    private func familyTag(_ name: String) -> some View {
        Text(name)
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 12)
            .padding( .vertical, 5)
            .background( .white.opacity(0.15))
            .foregroundStyle(.white)
            .clipShape(Capsule())
        }
    
    private func familyColor(_ family: FragranceFamily) -> Color {
            switch family {
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
    
    private var topFamilies: [String] {
            sortedFamilies
                .prefix(3)
                .map { $0.key.rawValue }
        }

        private var sortedFamilies: [(key: FragranceFamily, count: Int)] {
            profile.familyDistribution
                .sorted { $0.value > $1.value }
                .map { (key: $0.key, count: $0.value) }
        }

        private func barWidth(for count: Int) -> CGFloat {
            let max = profile.familyDistribution.values.max() ?? 1
            return CGFloat(count) / CGFloat(max)
        }

        private var blobConfigs: [BlobConfig] {
            let colors = profile.auraColors.compactMap { Color(hex: $0) }
            let c1 = colors.count > 0 ? colors[0] : .purple
            let c2 = colors.count > 1 ? colors[1] : .orange
            
            return [
                    BlobConfig(color: c1,    size: 280, fromX: -60,  fromY: -80,  toX: -30,  toY: -40,  toScale: 1.15, duration: 9,  delay: 0),
                    BlobConfig(color: c2,    size: 240, fromX: 60,   fromY: 40,   toX: 20,   toY: 60,   toScale: 0.9,  duration: 11, delay: 1),
                    BlobConfig(color: c1.opacity(0.6), size: 200, fromX: 20, fromY: -60, toX: -20, toY: 20, toScale: 1.1, duration: 13, delay: 2),
                    BlobConfig(color: c2.opacity(0.5), size: 160, fromX: -40, fromY: 60, toX: 40, toY: -20, toScale: 1.2, duration: 7, delay: 0.5)
                    ]
                }
    
    // MARK: - Blobconfig
    private struct BlobConfig {
        let color: Color
        let size: CGFloat
        let fromX: CGFloat
        let fromY: CGFloat
        let toX: CGFloat
        let toY: CGFloat
        let toScale: CGFloat
        let duration: Double
        let delay: Double
    }
    
   
}

// MARK: - Color Extension
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
        
#Preview {
    ScentAuraView(profile: ScentProfile(
        dominantFamily: .woody,
        secondFamily: .oriental,
        topNotes: ["Bergamot", "Sandalwood", "Cedar"],
        familyDistribution: [
            .woody: 3,
            .oriental: 2,
            .fresh: 1
        ]
    ))
}
