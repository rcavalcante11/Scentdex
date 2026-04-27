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
    @State private var selectedFragrance: FragranceResult? = nil
    
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
        VStack(alignment: .leading, spacing: 4) {
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
    
    private func carouselView(_ perfumes: [FragranceResult]) -> some View {
        let limited = Array(perfumes.prefix(3))

        return ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(Array(limited.enumerated()), id: \.element.id) { index, perfume in
                    if index < 2 {
                        // Cards 1 e 2 — tappable
                        Button {
                            selectedFragrance = perfume
                        } label: {
                            RecommendationCardView(fragrance: perfume)
                        }
                        .buttonStyle(.plain)
                    } else {
                        // Card 3 — blur premium
                        RecommendationCardView(fragrance: perfume)
                            .blur(radius: 6)
                            .overlay {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(.ultraThinMaterial)
                                VStack(spacing: 8) {
                                    Image(systemName: "lock.fill")
                                        .font(.title2)
                                        .foregroundStyle(.secondary)
                                    Text("Available on Premium")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(.secondary)
                                }
                            }
                    }
                }
            }
            .scrollTargetLayout()
            .padding(.horizontal, 24)
        }
        .scrollTargetBehavior(.viewAligned)
        .sheet(item: $selectedFragrance) { fragrance in
            RecommendationDetailSheet(
                fragrance: fragrance,
                ownedPerfumes: ownedPerfumes
            )
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
    }
    
    private var emptyView: some View {
        Text("No recommendations available yet")
            .font(.subheadline)
            .foregroundColor(.secondary)
            .padding(.horizontal,24)
        
            }
        }


