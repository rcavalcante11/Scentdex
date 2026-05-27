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
            let ownedNames = Set(ownedPerfumes.map { $0.name.lowercased() })
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
                FragranceResult(id: "m1", name: "Terre d'Hermès", brand: "Hermès", family: "woody", topNotes: ["Grapefruit"], middleNotes: ["Pepper"], baseNotes: ["Vetiver"], gender: "men", imageUrl: nil),
                FragranceResult(id: "m2", name: "Oud Wood", brand: "Tom Ford", family: "woody", topNotes: ["Rosewood"], middleNotes: ["Oud"], baseNotes: ["Amber"], gender: "unisex", imageUrl: nil),
                FragranceResult(id: "m3", name: "Bois du Portugal", brand: "Creed", family: "woody", topNotes: ["Bergamot"], middleNotes: ["Lavender"], baseNotes: ["Cedar"], gender: "men", imageUrl: nil)
            ]
        case .floral:
            mock = [
                FragranceResult(id: "m4", name: "Miss Dior", brand: "Dior", family: "floral", topNotes: ["Bergamot"], middleNotes: ["Rose"], baseNotes: ["Patchouli"], gender: "women", imageUrl: nil),
                FragranceResult(id: "m5", name: "Flowerbomb", brand: "Viktor & Rolf", family: "floral", topNotes: ["Tea"], middleNotes: ["Jasmine"], baseNotes: ["Patchouli"], gender: "women", imageUrl: nil),
                FragranceResult(id: "m6", name: "J'adore", brand: "Dior", family: "floral", topNotes: ["Pear"], middleNotes: ["Rose"], baseNotes: ["Musk"], gender: "women", imageUrl: nil)
            ]
        case .oriental:
            mock = [
                FragranceResult(id: "m7", name: "Black Opium", brand: "YSL", family: "oriental", topNotes: ["Pink Pepper"], middleNotes: ["Coffee"], baseNotes: ["Vanilla"], gender: "women", imageUrl: nil),
                FragranceResult(id: "m8", name: "Baccarat Rouge 540", brand: "MFK", family: "oriental", topNotes: ["Jasmine"], middleNotes: ["Amberwood"], baseNotes: ["Cedar"], gender: "unisex", imageUrl: nil),
                FragranceResult(id: "m9", name: "Good Girl", brand: "Carolina Herrera", family: "oriental", topNotes: ["Almond"], middleNotes: ["Tuberose"], baseNotes: ["Cocoa"], gender: "women", imageUrl: nil)
            ]
        case .citrus:
            mock = [
                FragranceResult(id: "m10", name: "Acqua di Gio", brand: "Armani", family: "aquatic", topNotes: ["Bergamot"], middleNotes: ["Marine"], baseNotes: ["Cedar"], gender: "men", imageUrl: nil),
                FragranceResult(id: "m11", name: "Light Blue", brand: "D&G", family: "citrus", topNotes: ["Lemon"], middleNotes: ["Bamboo"], baseNotes: ["Musk"], gender: "unisex", imageUrl: nil),
                FragranceResult(id: "m12", name: "Aventus", brand: "Creed", family: "fresh", topNotes: ["Pineapple"], middleNotes: ["Birch"], baseNotes: ["Musk"], gender: "men", imageUrl: nil)
            ]
        case .aquatic:
            mock = [
                FragranceResult(id: "m13", name: "Acqua di Gio", brand: "Armani", family: "aquatic", topNotes: ["Bergamot"], middleNotes: ["Marine"], baseNotes: ["Cedar"], gender: "men", imageUrl: nil),
                FragranceResult(id: "m14", name: "Cool Water", brand: "Davidoff", family: "aquatic", topNotes: ["Mint"], middleNotes: ["Lavender"], baseNotes: ["Musk"], gender: "men", imageUrl: nil),
                FragranceResult(id: "m15", name: "L'Eau d'Issey", brand: "Issey Miyake", family: "aquatic", topNotes: ["Lotus"], middleNotes: ["Freesia"], baseNotes: ["Cedar"], gender: "women", imageUrl: nil)
            ]
        case .fresh:
            mock = [
                FragranceResult(id: "m16", name: "Aventus", brand: "Creed", family: "fresh", topNotes: ["Pineapple"], middleNotes: ["Birch"], baseNotes: ["Musk"], gender: "men", imageUrl: nil),
                FragranceResult(id: "m17", name: "Green Irish Tweed", brand: "Creed", family: "fresh", topNotes: ["Lemon"], middleNotes: ["Iris"], baseNotes: ["Sandalwood"], gender: "men", imageUrl: nil),
                FragranceResult(id: "m18", name: "CK One", brand: "Calvin Klein", family: "fresh", topNotes: ["Bergamot"], middleNotes: ["Jasmine"], baseNotes: ["Musk"], gender: "unisex", imageUrl: nil)
            ]
        case .gourmand:
            mock = [
                FragranceResult(id: "m19", name: "Angel", brand: "Mugler", family: "gourmand", topNotes: ["Bergamot"], middleNotes: ["Honey"], baseNotes: ["Vanilla"], gender: "women", imageUrl: nil),
                FragranceResult(id: "m20", name: "La Vie Est Belle", brand: "Lancôme", family: "gourmand", topNotes: ["Pear"], middleNotes: ["Iris"], baseNotes: ["Praline"], gender: "women", imageUrl: nil),
                FragranceResult(id: "m21", name: "Black Opium", brand: "YSL", family: "gourmand", topNotes: ["Pink Pepper"], middleNotes: ["Coffee"], baseNotes: ["Vanilla"], gender: "women", imageUrl: nil)
            ]
        case .spicy:
            mock = [
                FragranceResult(id: "m22", name: "Spicebomb", brand: "Viktor & Rolf", family: "spicy", topNotes: ["Bergamot"], middleNotes: ["Cinnamon"], baseNotes: ["Leather"], gender: "men", imageUrl: nil),
                FragranceResult(id: "m23", name: "Opium", brand: "YSL", family: "spicy", topNotes: ["Pepper"], middleNotes: ["Jasmine"], baseNotes: ["Patchouli"], gender: "women", imageUrl: nil),
                FragranceResult(id: "m24", name: "Santal 33", brand: "Le Labo", family: "spicy", topNotes: ["Cardamom"], middleNotes: ["Iris"], baseNotes: ["Sandalwood"], gender: "unisex", imageUrl: nil)
            ]
        case .herbal:
            mock = [
                FragranceResult(id: "m25", name: "Fahrenheit", brand: "Dior", family: "herbal", topNotes: ["Lavender"], middleNotes: ["Nutmeg"], baseNotes: ["Vetiver"], gender: "men", imageUrl: nil),
                FragranceResult(id: "m26", name: "Polo Green", brand: "Ralph Lauren", family: "herbal", topNotes: ["Basil"], middleNotes: ["Pine"], baseNotes: ["Oakmoss"], gender: "men", imageUrl: nil),
                FragranceResult(id: "m27", name: "Eau Sauvage", brand: "Dior", family: "herbal", topNotes: ["Lemon"], middleNotes: ["Rosemary"], baseNotes: ["Oakmoss"], gender: "men", imageUrl: nil)
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
