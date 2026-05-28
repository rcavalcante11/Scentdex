import Foundation
import Observation

@Observable
class RecommendationViewModel {

    // MARK: - Properties
    private(set) var state: RecommendationState = .idle
    private var refreshCount = 0
    
    var isLoading: Bool {
           if case .loading = state { return true }
           return false
       }

    // MARK: - Intent
    @MainActor
    func loadRecommendations(
        profile: ScentProfile,
        ownedPerfumes: [Perfume]
    ) async {
        await load(profile: profile, ownedPerfumes: ownedPerfumes)
    }

    @MainActor
    func refresh(profile: ScentProfile, ownedPerfumes: [Perfume]) async {
        refreshCount += 1
        await load(profile: profile, ownedPerfumes: ownedPerfumes)
    }
    
    
    @MainActor
    private func load(
        profile: ScentProfile,
        ownedPerfumes: [Perfume]
    ) async {
        state = .loading
        do {
            let results = try await fetchCandidates(for: profile)
            let ownedNames = Set(ownedPerfumes.map { $0.name.lowercased() })
            let dominantGender = calculateDominantGender(from: ownedPerfumes)

            let filtered = results
                .filter { !ownedNames.contains($0.name.lowercased()) }
                .filter { genderMatches($0.gender, dominantGender: dominantGender) }

            state = filtered.isEmpty ? .empty : .loaded(filtered)
        } catch {
            let dominantGender = calculateDominantGender(from: ownedPerfumes)
            state = useMockData(for: profile, dominantGender: dominantGender)
        }
    }

    // MARK: - Gender Logic
    private func calculateDominantGender(from perfumes: [Perfume]) -> PerfumeGender {
        var counts: [PerfumeGender: Int] = [:]
        for perfume in perfumes {
            counts[perfume.gender, default: 0] += 1
        }
        // Se mais de 60% for de um género específico — filtra por esse género
        let total = perfumes.count
        if let dominant = counts.max(by: { $0.value < $1.value }) {
            let ratio = Double(dominant.value) / Double(total)
            if ratio >= 0.6 && dominant.key != .forWomenAndMen {
                return dominant.key
            }
        }
        return .forWomenAndMen
    }

    private func genderMatches(_ gender: String?, dominantGender: PerfumeGender) -> Bool {
        guard dominantGender != .forWomenAndMen else { return true }

        let g = gender?.lowercased() ?? "unisex"

        // Unisex aparece sempre
        if g == "unisex" { return true }

        switch dominantGender {
        case .forMen:    return g == "men" || g == "masculine"
        case .forWomen:  return g == "women" || g == "feminine"
        default:         return true
        }
    }

    private func fetchCandidates(for profile: ScentProfile) async throws -> [FragranceResult] {
        print("🔄 Refresh count: \(refreshCount), strategy: \(refreshCount % 3)")
        let notes = profile.topNotes
        guard !notes.isEmpty else {
            return try await PerfumeService.shared.searchPerfumes(query: profile.dominantFamily.rawValue)
        }

        switch refreshCount % 3 {
        case 0:
            // Notas do início — mais frequentes
            let query = notes.prefix(4).joined(separator: ",")
            return try await PerfumeService.shared.searchByNotes(notes: query)
        case 1:
            // Notas do meio
            let mid = notes.dropFirst(3).prefix(4)
            let query = mid.isEmpty ? notes.suffix(4).joined(separator: ",") : mid.joined(separator: ",")
            return try await PerfumeService.shared.searchByNotes(notes: query)
        default:
            // Busca por família
            return try await PerfumeService.shared.searchPerfumes(query: profile.dominantFamily.rawValue)
        }
    }

    // MARK: - Mock
    private func useMockData(for profile: ScentProfile, dominantGender: PerfumeGender) -> RecommendationState {
        let mock = mockResults(for: profile.dominantFamily)
        let filtered = mock.filter { genderMatches($0.gender, dominantGender: dominantGender) }
        return filtered.isEmpty ? .loaded(mock) : .loaded(filtered)
    }

    private func mockResults(for family: FragranceFamily) -> [FragranceResult] {
        switch family {
        case .woody:
            return [
                FragranceResult(id: "m1", name: "Terre d'Hermès", brand: "Hermès", family: "woody", topNotes: ["Grapefruit"], middleNotes: ["Pepper"], baseNotes: ["Vetiver"], gender: "men", imageUrl: "https://cdn.fragella.com/images/terre-d-hermes-hermes-for-men.webp"),
                FragranceResult(id: "m2", name: "Oud Wood", brand: "Tom Ford", family: "woody", topNotes: ["Rosewood"], middleNotes: ["Oud"], baseNotes: ["Amber"], gender: "unisex", imageUrl: "https://cdn.fragella.com/images/oud-wood-tom-ford-unisex.webp"),
                FragranceResult(id: "m3", name: "Aventus", brand: "Creed", family: "woody", topNotes: ["Pineapple"], middleNotes: ["Birch"], baseNotes: ["Musk"], gender: "men", imageUrl: "https://cdn.fragella.com/images/aventus-creed-for-men.webp"),
                FragranceResult(id: "m4", name: "Bleu de Chanel", brand: "Chanel", family: "woody", topNotes: ["Bergamot"], middleNotes: ["Ginger"], baseNotes: ["Cedar"], gender: "men", imageUrl: "https://cdn.fragella.com/images/bleu-de-chanel-chanel-for-men.webp"),
                FragranceResult(id: "m5", name: "Dior Sauvage", brand: "Dior", family: "woody", topNotes: ["Bergamot"], middleNotes: ["Pepper"], baseNotes: ["Ambroxan"], gender: "men", imageUrl: "https://cdn.fragella.com/images/sauvage-christian-dior-for-men.webp")
            ]
        case .floral:
            return [
                FragranceResult(id: "m6", name: "Miss Dior", brand: "Dior", family: "floral", topNotes: ["Bergamot"], middleNotes: ["Rose"], baseNotes: ["Patchouli"], gender: "women", imageUrl: "https://cdn.fragella.com/images/miss-dior-christian-dior-for-women.webp"),
                FragranceResult(id: "m7", name: "Flowerbomb", brand: "Viktor & Rolf", family: "floral", topNotes: ["Tea"], middleNotes: ["Jasmine"], baseNotes: ["Patchouli"], gender: "women", imageUrl: "https://cdn.fragella.com/images/flowerbomb-viktor-rolf-for-women.webp"),
                FragranceResult(id: "m8", name: "J'adore", brand: "Dior", family: "floral", topNotes: ["Pear"], middleNotes: ["Rose"], baseNotes: ["Musk"], gender: "women", imageUrl: "https://cdn.fragella.com/images/j-adore-christian-dior-for-women.webp"),
                FragranceResult(id: "m9", name: "Chance", brand: "Chanel", family: "floral", topNotes: ["Citrus"], middleNotes: ["Iris"], baseNotes: ["Patchouli"], gender: "women", imageUrl: "https://cdn.fragella.com/images/chance-chanel-for-women.webp"),
                FragranceResult(id: "m10", name: "Light Blue", brand: "D&G", family: "floral", topNotes: ["Lemon"], middleNotes: ["Bamboo"], baseNotes: ["Musk"], gender: "women", imageUrl: "https://cdn.fragella.com/images/light-blue-dolce-gabbana-for-women.webp")
            ]
        case .oriental:
            return [
                FragranceResult(id: "m11", name: "Black Opium", brand: "YSL", family: "oriental", topNotes: ["Pink Pepper"], middleNotes: ["Coffee"], baseNotes: ["Vanilla"], gender: "women", imageUrl: "https://cdn.fragella.com/images/black-opium-yves-saint-laurent-for-women.webp"),
                FragranceResult(id: "m12", name: "Baccarat Rouge 540", brand: "MFK", family: "oriental", topNotes: ["Jasmine"], middleNotes: ["Amberwood"], baseNotes: ["Cedar"], gender: "unisex", imageUrl: "https://cdn.fragella.com/images/baccarat-rouge-540-maison-francis-kurkdjian-unisex.webp"),
                FragranceResult(id: "m13", name: "Spicebomb Extreme", brand: "Viktor & Rolf", family: "oriental", topNotes: ["Grapefruit"], middleNotes: ["Cinnamon"], baseNotes: ["Vanilla"], gender: "men", imageUrl: "https://cdn.fragella.com/images/spicebomb-extreme-viktor-rolf-for-men.webp"),
                FragranceResult(id: "m14", name: "Aventus", brand: "Creed", family: "oriental", topNotes: ["Pineapple"], middleNotes: ["Birch"], baseNotes: ["Musk"], gender: "men", imageUrl: "https://cdn.fragella.com/images/aventus-creed-for-men.webp"),
                FragranceResult(id: "m15", name: "Opium pour Homme", brand: "YSL", family: "oriental", topNotes: ["Pepper"], middleNotes: ["Jasmine"], baseNotes: ["Patchouli"], gender: "men", imageUrl: "https://cdn.fragella.com/images/opium-pour-homme-yves-saint-laurent-for-men.webp")
            ]
        case .citrus:
            return [
                FragranceResult(id: "m16", name: "Acqua di Gio", brand: "Armani", family: "aquatic", topNotes: ["Bergamot"], middleNotes: ["Marine"], baseNotes: ["Cedar"], gender: "men", imageUrl: "https://cdn.fragella.com/images/acqua-di-gio-giorgio-armani-for-men.webp"),
                FragranceResult(id: "m17", name: "Light Blue", brand: "D&G", family: "citrus", topNotes: ["Lemon"], middleNotes: ["Bamboo"], baseNotes: ["Musk"], gender: "unisex", imageUrl: "https://cdn.fragella.com/images/light-blue-dolce-gabbana-for-men.webp"),
                FragranceResult(id: "m18", name: "Aventus", brand: "Creed", family: "fresh", topNotes: ["Pineapple"], middleNotes: ["Birch"], baseNotes: ["Musk"], gender: "men", imageUrl: "https://cdn.fragella.com/images/aventus-creed-for-men.webp"),
                FragranceResult(id: "m19", name: "Versace Eros", brand: "Versace", family: "citrus", topNotes: ["Mint"], middleNotes: ["Tonka Bean"], baseNotes: ["Vanilla"], gender: "men", imageUrl: "https://cdn.fragella.com/images/versace-eros.webp"),
                FragranceResult(id: "m20", name: "Dior Sauvage", brand: "Dior", family: "citrus", topNotes: ["Bergamot"], middleNotes: ["Pepper"], baseNotes: ["Ambroxan"], gender: "men", imageUrl: "https://cdn.fragella.com/images/sauvage-christian-dior-for-men.webp")
            ]
        case .aquatic:
            return [
                FragranceResult(id: "m21", name: "Acqua di Gio", brand: "Armani", family: "aquatic", topNotes: ["Bergamot"], middleNotes: ["Marine"], baseNotes: ["Cedar"], gender: "men", imageUrl: "https://cdn.fragella.com/images/acqua-di-gio-giorgio-armani-for-men.webp"),
                FragranceResult(id: "m22", name: "Cool Water", brand: "Davidoff", family: "aquatic", topNotes: ["Mint"], middleNotes: ["Lavender"], baseNotes: ["Musk"], gender: "men", imageUrl: "https://cdn.fragella.com/images/cool-water-davidoff-for-men.webp"),
                FragranceResult(id: "m23", name: "L'Eau d'Issey pour Homme", brand: "Issey Miyake", family: "aquatic", topNotes: ["Lotus"], middleNotes: ["Freesia"], baseNotes: ["Cedar"], gender: "men", imageUrl: "https://cdn.fragella.com/images/l-eau-d-issey-pour-homme-issey-miyake-for-men.webp"),
                FragranceResult(id: "m24", name: "Bleu de Chanel", brand: "Chanel", family: "aquatic", topNotes: ["Bergamot"], middleNotes: ["Ginger"], baseNotes: ["Cedar"], gender: "men", imageUrl: "https://cdn.fragella.com/images/bleu-de-chanel-chanel-for-men.webp"),
                FragranceResult(id: "m25", name: "Dior Sauvage", brand: "Dior", family: "aquatic", topNotes: ["Bergamot"], middleNotes: ["Pepper"], baseNotes: ["Ambroxan"], gender: "men", imageUrl: "https://cdn.fragella.com/images/sauvage-christian-dior-for-men.webp")
            ]
        case .fresh:
            return [
                FragranceResult(id: "m26", name: "Aventus", brand: "Creed", family: "fresh", topNotes: ["Pineapple"], middleNotes: ["Birch"], baseNotes: ["Musk"], gender: "men", imageUrl: "https://cdn.fragella.com/images/aventus-creed-for-men.webp"),
                FragranceResult(id: "m27", name: "Green Irish Tweed", brand: "Creed", family: "fresh", topNotes: ["Lemon"], middleNotes: ["Iris"], baseNotes: ["Sandalwood"], gender: "men", imageUrl: "https://cdn.fragella.com/images/green-irish-tweed-creed-for-men.webp"),
                FragranceResult(id: "m28", name: "CK One", brand: "Calvin Klein", family: "fresh", topNotes: ["Bergamot"], middleNotes: ["Jasmine"], baseNotes: ["Musk"], gender: "unisex", imageUrl: "https://cdn.fragella.com/images/ck-one-calvin-klein-unisex.webp"),
                FragranceResult(id: "m29", name: "Dior Sauvage", brand: "Dior", family: "fresh", topNotes: ["Bergamot"], middleNotes: ["Pepper"], baseNotes: ["Ambroxan"], gender: "men", imageUrl: "https://cdn.fragella.com/images/sauvage-christian-dior-for-men.webp"),
                FragranceResult(id: "m30", name: "Versace Eros", brand: "Versace", family: "fresh", topNotes: ["Mint"], middleNotes: ["Tonka Bean"], baseNotes: ["Vanilla"], gender: "men", imageUrl: "https://cdn.fragella.com/images/versace-eros.webp")
            ]
        case .gourmand:
            return [
                FragranceResult(id: "m31", name: "Angel Men", brand: "Mugler", family: "gourmand", topNotes: ["Bergamot"], middleNotes: ["Honey"], baseNotes: ["Vanilla"], gender: "men", imageUrl: "https://cdn.fragella.com/images/angel-men-mugler-for-men.webp"),
                FragranceResult(id: "m32", name: "La Vie Est Belle", brand: "Lancôme", family: "gourmand", topNotes: ["Pear"], middleNotes: ["Iris"], baseNotes: ["Praline"], gender: "women", imageUrl: "https://cdn.fragella.com/images/la-vie-est-belle-lancome-for-women.webp"),
                FragranceResult(id: "m33", name: "Black Opium", brand: "YSL", family: "gourmand", topNotes: ["Pink Pepper"], middleNotes: ["Coffee"], baseNotes: ["Vanilla"], gender: "women", imageUrl: "https://cdn.fragella.com/images/black-opium-yves-saint-laurent-for-women.webp"),
                FragranceResult(id: "m34", name: "Baccarat Rouge 540", brand: "MFK", family: "gourmand", topNotes: ["Jasmine"], middleNotes: ["Amberwood"], baseNotes: ["Cedar"], gender: "unisex", imageUrl: "https://cdn.fragella.com/images/baccarat-rouge-540-maison-francis-kurkdjian-unisex.webp"),
                FragranceResult(id: "m35", name: "Spicebomb Extreme", brand: "Viktor & Rolf", family: "gourmand", topNotes: ["Grapefruit"], middleNotes: ["Cinnamon"], baseNotes: ["Vanilla"], gender: "men", imageUrl: "https://cdn.fragella.com/images/spicebomb-extreme-viktor-rolf-for-men.webp")
            ]
        case .spicy:
            return [
                FragranceResult(id: "m36", name: "Spicebomb", brand: "Viktor & Rolf", family: "spicy", topNotes: ["Bergamot"], middleNotes: ["Cinnamon"], baseNotes: ["Leather"], gender: "men", imageUrl: "https://cdn.fragella.com/images/spicebomb-viktor-rolf-for-men.webp"),
                FragranceResult(id: "m37", name: "Santal 33", brand: "Le Labo", family: "spicy", topNotes: ["Cardamom"], middleNotes: ["Iris"], baseNotes: ["Sandalwood"], gender: "unisex", imageUrl: "https://cdn.fragella.com/images/santal-33-le-labo-unisex.webp"),
                FragranceResult(id: "m38", name: "Dior Sauvage", brand: "Dior", family: "spicy", topNotes: ["Bergamot"], middleNotes: ["Pepper"], baseNotes: ["Ambroxan"], gender: "men", imageUrl: "https://cdn.fragella.com/images/sauvage-christian-dior-for-men.webp"),
                FragranceResult(id: "m39", name: "Versace Eros", brand: "Versace", family: "spicy", topNotes: ["Mint"], middleNotes: ["Tonka Bean"], baseNotes: ["Vanilla"], gender: "men", imageUrl: "https://cdn.fragella.com/images/versace-eros.webp"),
                FragranceResult(id: "m40", name: "Terre d'Hermès", brand: "Hermès", family: "spicy", topNotes: ["Grapefruit"], middleNotes: ["Pepper"], baseNotes: ["Vetiver"], gender: "men", imageUrl: "https://cdn.fragella.com/images/terre-d-hermes-hermes-for-men.webp")
            ]
        case .herbal:
            return [
                FragranceResult(id: "m41", name: "Fahrenheit", brand: "Dior", family: "herbal", topNotes: ["Lavender"], middleNotes: ["Nutmeg"], baseNotes: ["Vetiver"], gender: "men", imageUrl: "https://cdn.fragella.com/images/fahrenheit-christian-dior-for-men.webp"),
                FragranceResult(id: "m42", name: "Polo Green", brand: "Ralph Lauren", family: "herbal", topNotes: ["Basil"], middleNotes: ["Pine"], baseNotes: ["Oakmoss"], gender: "men", imageUrl: "https://cdn.fragella.com/images/polo-ralph-lauren-for-men.webp"),
                FragranceResult(id: "m43", name: "Eau Sauvage", brand: "Dior", family: "herbal", topNotes: ["Lemon"], middleNotes: ["Rosemary"], baseNotes: ["Oakmoss"], gender: "men", imageUrl: "https://cdn.fragella.com/images/eau-sauvage-christian-dior-for-men.webp"),
                FragranceResult(id: "m44", name: "Green Irish Tweed", brand: "Creed", family: "herbal", topNotes: ["Lemon"], middleNotes: ["Iris"], baseNotes: ["Sandalwood"], gender: "men", imageUrl: "https://cdn.fragella.com/images/green-irish-tweed-creed-for-men.webp"),
                FragranceResult(id: "m45", name: "Versace Eros", brand: "Versace", family: "herbal", topNotes: ["Mint"], middleNotes: ["Tonka Bean"], baseNotes: ["Vanilla"], gender: "men", imageUrl: "https://cdn.fragella.com/images/versace-eros.webp")
            ]
        }
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
