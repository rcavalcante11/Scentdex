//
//  RecommendationCarouselView.swift
//  Scentdex
//
//  Created by macbook on 17/04/2026.
//

import SwiftUI
import SwiftData

struct RecommendationCarouselView: View {
    
    // MARK: -  Properties
    let profile: ScentProfile
    @Query private var ownedPerfumes: [Perfume] 
    @State private var viewModel = RecommendationViewModel()
    
    // MARK: -  Body
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            headerView
            contentView
        }
        
        .task {
            await viewModel.loadRecommendations(profile: profile,
                ownedPerfumes: ownedPerfumes
                )
            }
        }
    
    private var headerView: some View {
        VStack(alignment: .trailing, spacing: 4) {
            Text("You might also like")
                .font(.title2)
                .fontWeight(.semibold)
            Text("Based on your \(profile.profileTitle) profile")
                .font(.caption)
                .foregroundStyle(.secondary)
            
                
        }
        .padding(.horizontal, 24)
    }
    
    private var contentView: some View {
        Group {
            switch viewModel.state {
            case .idle:
                EmptyView()
            case .loading:
                loadingView
            case .loaded(let perfumes):
                carouselView(perfumes)
            case .empty:
                EmptyView()
                case .error:
                EmptyView()
                }
            }
        }
    
    private var loadingView: some View {
        HStack(spacing: 12) {
            ForEach(0..<3,id: \.self) { _ in
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.secondary.opacity(0.15))
                    .frame(width: 160, height: 200)
            }
        }
        .padding(.horizontal, 24)
    }
    
    private func  carouselView(_ perfumes: [FragranceResult]) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(perfumes) { perfume in
                    RecommendationCardView(fragrance: perfume)
                }
            }
            .scrollTargetLayout()
            .padding(.horizontal,24)
            
            }
        
        .scrollTargetBehavior(.viewAligned)
        
            }
    
    private var emptyView: some View {
        Text("No recommendations available yet")
            .font(.subheadline)
            .foregroundColor(.secondary)
            .padding(.horizontal,24)
        
            }
        }


