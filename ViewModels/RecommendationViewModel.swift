//
//  RecommendationViewModel.swift
//  Scentdex
//
//  Created by macbook on 16/04/2026.
//

import Foundation
import Observation

@Observable
class RecommendationViewModel {
    
    // MARK: - Properties
    private(set) var state: RecommendationState = .idle
    
    
    // MARK: - Intent
    @MainActor
    func loadRecommendations(
        profile: ScentProfile,
        ownedPerfumes: [Perfume]
    ) async {
        state = .loading
        
        do {
            let results = try await fetchCandidates(for: profile)
            let ownedNames = Set(ownedPerfumes.map { $0.name.lowercased()} )
            let filtered = results.filter {
                !ownedNames.contains($0.name.lowercased())
            }
            
            
            state = filtered.isEmpty ? .empty : .loaded(filtered)
        } catch {
            state = useMockData(for: profile)
            }
        }
    
    // MARK: - Private
    private func fetchCandidates(for profile: ScentProfile) async throws -> [FragranceResult] {
        let topNotes = profile.topNotes
        
        if !topNotes.isEmpty {
            let notesQuery = topNotes.joined(separator: ",")
            return try await PerfumeService.shared.searchByNotes(notes: notesQuery)
        } else {
            let familyName = profile.dominantFamily.rawValue
            return try await PerfumeService.shared.searchPerfumes(query: familyName)
        }
    }
    
    private func useMockData(for profile: ScentProfile) -> RecommendationState {
        let mock: [FragranceResult]
        
        switch profile.dominantFamily {
        case .woody:
            mock = [
                FragranceResult(id: "m1", name: "Terre d'Hermès", brand: "Hermès", family: "woody", topNotes: ["Grapefruit"], middleNotes: ["Pepper"], baseNotes: ["Vetiver"], gender: "For Men", imageUrl: nil),
                FragranceResult(id: "m2", name: "Oud Wood", brand: "Tom Ford", family: "woody", topNotes: ["Rosewood"], middleNotes: ["Oud"], baseNotes: ["Amber"], gender: "For Women and Men", imageUrl: nil),
                FragranceResult(id: "m3", name: "Bois du Portugal", brand: "Creed", family: "woody", topNotes: ["Bergamot"], middleNotes: ["Lavender"], baseNotes: ["Cedar"], gender: "For Men", imageUrl: nil)
            ]
        case .floral:
            mock = [
                FragranceResult(id: "m4", name: "Miss Dior", brand: "Dior", family: "floral", topNotes: ["Bergamot"], middleNotes: ["Rose"], baseNotes: ["Patchouli"], gender: "For Women", imageUrl: nil),
                FragranceResult(id: "m5", name: "Flowerbomb", brand: "Viktor & Rolf", family: "floral", topNotes: ["Tea"], middleNotes: ["Jasmine"], baseNotes: ["Patchouli"], gender: "For Women", imageUrl: nil),
                FragranceResult(id: "m6", name: "J'adore", brand: "Dior", family: "floral", topNotes: ["Pear"], middleNotes: ["Rose"], baseNotes: ["Musk"], gender: "For Women", imageUrl: nil)
            ]
        case .oriental:
            mock = [
                FragranceResult(id: "m7", name: "Black Opium", brand: "YSL", family: "oriental", topNotes: ["Pink Pepper"], middleNotes: ["Coffee"], baseNotes: ["Vanilla"], gender: "For Women", imageUrl: nil),
                FragranceResult(id: "m8", name: "Baccarat Rouge 540", brand: "MFK", family: "oriental", topNotes: ["Jasmine"], middleNotes: ["Amberwood"], baseNotes: ["Cedar"], gender: "For Women and Men", imageUrl: nil),
                FragranceResult(id: "m9", name: "Good Girl", brand: "Carolina Herrera", family: "oriental", topNotes: ["Almond"], middleNotes: ["Tuberose"], baseNotes: ["Cocoa"], gender: "For Women", imageUrl: nil)
            ]
        default:
            mock = [
                FragranceResult(id: "m10", name: "Acqua di Gio", brand: "Armani", family: "aquatic", topNotes: ["Bergamot"], middleNotes: ["Marine"], baseNotes: ["Cedar"], gender: "For Men", imageUrl: nil),
                FragranceResult(id: "m11", name: "Light Blue", brand: "D&G", family: "citrus", topNotes: ["Lemon"], middleNotes: ["Bamboo"], baseNotes: ["Musk"], gender: "For Women and Men", imageUrl: nil),
                FragranceResult(id: "m12", name: "Aventus", brand: "Creed", family: "fresh", topNotes: ["Pineapple"], middleNotes: ["Birch"], baseNotes: ["Musk"], gender: "For Men", imageUrl: nil)
            ]
        }
        
        return .loaded(mock)
    }
}

// MARK: - State
enum RecommendationState {
    case idle
    case loading
    case loaded([FragranceResult])
    case empty
    case error
}

