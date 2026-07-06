import Foundation
import Observation

@Observable
class RecommendationViewModel {

    // MARK: - State
    enum State {
        case idle
        case loading
        case loaded([FragranceResult])
        case empty
        case error
    }

    // MARK: - Properties
    private(set) var state: State = .idle
    private var refreshCount = 0
    private var seenIds: Set<String> = []

    // MARK: - Intent
    @MainActor
    func loadRecommendations(profile: ScentProfile, ownedPerfumes: [Perfume]) async {
        guard case .idle = state else { return }
        state = .loading
        await fetchAndUpdate(profile: profile, ownedPerfumes: ownedPerfumes)
    }

    @MainActor
    func refresh(profile: ScentProfile, ownedPerfumes: [Perfume]) async {
        state = .loading
        refreshCount += 1
        await fetchAndUpdate(profile: profile, ownedPerfumes: ownedPerfumes)
    }

    // MARK: - Private
    @MainActor
    private func fetchAndUpdate(profile: ScentProfile, ownedPerfumes: [Perfume]) async {
        do {
            var candidates = try await fetchCandidates(for: profile, ownedPerfumes: ownedPerfumes)
            candidates = filter(candidates, excluding: ownedPerfumes)
            candidates = candidates.filter { !seenIds.contains($0.id) }

            // Se ficou vazio depois de filtrar, limpa histórico e tenta de novo
            if candidates.isEmpty {
                seenIds.removeAll()
                candidates = try await fetchCandidates(for: profile, ownedPerfumes: ownedPerfumes)
                candidates = filter(candidates, excluding: ownedPerfumes)
            }

            candidates.forEach { seenIds.insert($0.id) }
            state = candidates.isEmpty ? .empty : .loaded(candidates)

        } catch {
            print("❌ Recommendation error:", error.localizedDescription)
            let filtered = filter(mockResults, excluding: ownedPerfumes)
            state = filtered.isEmpty ? .empty : .loaded(filtered)
        }
    }

    private func fetchCandidates(for profile: ScentProfile, ownedPerfumes: [Perfume]) async throws -> [FragranceResult] {
        if refreshCount % 2 == 0 {
            return try await fetchAccordMix(for: profile)
        } else {
            return try await fetchSimilarFromDeck(ownedPerfumes: ownedPerfumes, profile: profile)
        }
    }

    // MARK: - Accord Mix (par)
    private func fetchAccordMix(for profile: ScentProfile) async throws -> [FragranceResult] {
        let userAccordNames = Set(profile.topAccords.map { $0.name.lowercased() })
        let top2 = profile.topAccords.prefix(2).map { $0.name.capitalized }
        let surprise = surpriseAccord(for: profile.dominantFamily, excluding: userAccordNames)

        let accordString = (top2 + [surprise])
            .map { "\($0):\(Int.random(in: 20...40))" }
            .joined(separator: ",")

        return try await PerfumeService.shared.searchByAccords(accords: accordString)
    }

    // MARK: - Similar From Deck (ímpar)
    private func fetchSimilarFromDeck(ownedPerfumes: [Perfume], profile: ScentProfile) async throws -> [FragranceResult] {
        guard let randomPerfume = ownedPerfumes.randomElement() else {
            return try await PerfumeService.shared.searchPerfumes(query: profile.dominantFamily.rawValue)
        }
        return try await PerfumeService.shared.fetchSimilar(to: randomPerfume.name)
    }

    // MARK: - Surprise Accord
    private func surpriseAccord(for family: FragranceFamily, excluding userAccords: Set<String>) -> String {
        let complementary: [FragranceFamily: [String]] = [
            .woody:    ["iris", "tobacco", "vetiver", "cardamom", "leather", "incense", "moss"],
            .oriental: ["rose", "saffron", "myrrh", "benzoin", "labdanum", "frankincense"],
            .floral:   ["musk", "sandalwood", "peach", "lychee", "raspberry", "aldehydes"],
            .fresh:    ["ginger", "basil", "mint", "sea salt", "ozonic", "white tea"],
            .citrus:   ["neroli", "petitgrain", "verbena", "yuzu", "elemi", "galbanum"],
            .aquatic:  ["driftwood", "sea moss", "ambergris", "ozone", "calone"],
            .gourmand: ["praline", "tonka", "heliotrope", "benzyl", "rum", "fig"],
            .spicy:    ["clove", "cumin", "pink pepper", "bay leaf", "anise", "ginger"],
            .herbal:   ["geranium", "thyme", "clary sage", "immortelle", "hay", "chamomile"]
        ]

        let candidates = complementary[family, default: ["musk", "amber", "cedar"]]
            .filter { !userAccords.contains($0.lowercased()) }

        return candidates.randomElement()?.capitalized ?? "Musk"
    }

    // MARK: - Filter
    private func filter(_ results: [FragranceResult], excluding owned: [Perfume]) -> [FragranceResult] {
        let ownedIds = Set(owned.map { "\($0.name.lowercased())-\($0.brand.lowercased())" })
        return results.filter { !ownedIds.contains($0.id) }
    }

    // MARK: - Mock Fallback
    private var mockResults: [FragranceResult] {
        [
            FragranceResult(
                id: "sauvage-dior",
                name: "Sauvage",
                brand: "Dior",
                family: "fresh",
                topNotes: ["Bergamot"],
                middleNotes: ["Pepper", "Lavender"],
                baseNotes: ["Ambroxan", "Cedar"],
                gender: "men"
            ),
            FragranceResult(
                id: "bleu-de-chanel",
                name: "Bleu de Chanel",
                brand: "Chanel",
                family: "woody",
                topNotes: ["Bergamot", "Lemon"],
                middleNotes: ["Ginger", "Nutmeg"],
                baseNotes: ["Sandalwood", "Cedar"],
                gender: "men"
            ),
            FragranceResult(
                id: "black-opium-ysl",
                name: "Black Opium",
                brand: "YSL",
                family: "oriental",
                topNotes: ["Pink Pepper", "Orange Blossom"],
                middleNotes: ["Coffee", "Jasmine"],
                baseNotes: ["Vanilla", "Patchouli"],
                gender: "women"
            ),
            FragranceResult(
                id: "light-blue-dg",
                name: "Light Blue",
                brand: "Dolce & Gabbana",
                family: "citrus",
                topNotes: ["Sicilian Lemon", "Apple"],
                middleNotes: ["Bamboo", "Jasmine"],
                baseNotes: ["Cedar", "Musk"],
                gender: "women"
            )
        ]
    }
}
