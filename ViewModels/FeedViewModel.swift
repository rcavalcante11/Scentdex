import Foundation
import Observation

// MARK: - Models
struct FeedArticle: Identifiable {
    let id: String
    let category: FeedCategory
    let title: String
    let summary: String
    let readTime: String
    let emoji: String
}

struct FeedFragrance: Identifiable {
    let id: String
    let name: String
    let brand: String
    let family: String
    let imageUrl: String?
}

enum FeedCategory: String {
    case tip        = "Tip"
    case guide      = "Guide"
    case ingredient = "Ingredient"
    case news       = "News"
}

// MARK: - ViewModel
@Observable
class FeedViewModel {

    // MARK: - Properties
    private(set) var articles: [FeedArticle] = []
    private(set) var trending: [FeedFragrance] = []
    private(set) var newReleases: [FeedFragrance] = []
    private(set) var isLoadingFragrances = false

    // MARK: - Intent
    func loadContent() async {
        loadArticles()
        await loadFragrances()
    }

    // MARK: - Private
    private func loadArticles() {
        articles = [
            FeedArticle(
                id: "a1",
                category: .guide,
                title: "EDP vs EDT — What Actually Changes",
                summary: "Concentration affects more than just longevity. It changes the character of a fragrance entirely — here's why.",
                readTime: "3 min",
                emoji: "🧪"
            ),
            FeedArticle(
                id: "a2",
                category: .tip,
                title: "The Right Way to Apply Fragrance",
                summary: "Pulse points matter — but the technique is more nuanced than most guides suggest. Moisture is the real key.",
                readTime: "2 min",
                emoji: "💡"
            ),
            FeedArticle(
                id: "a3",
                category: .ingredient,
                title: "What Is Oud — And Why Is It Everywhere",
                summary: "Agarwood is one of the most expensive raw materials in perfumery. Understanding it changes how you smell it.",
                readTime: "4 min",
                emoji: "🌿"
            ),
            FeedArticle(
                id: "a4",
                category: .tip,
                title: "Why Your Perfume Smells Different on Others",
                summary: "Skin chemistry, pH and diet all affect how a fragrance develops. Your skin is part of the composition.",
                readTime: "3 min",
                emoji: "🔬"
            ),
            FeedArticle(
                id: "a5",
                category: .guide,
                title: "Building a Capsule Fragrance Wardrobe",
                summary: "You don't need 30 bottles. Five well-chosen fragrances can cover every occasion and season.",
                readTime: "5 min",
                emoji: "👔"
            ),
            FeedArticle(
                id: "a6",
                category: .ingredient,
                title: "Bergamot — The Note That Starts Almost Everything",
                summary: "It's in hundreds of fragrances for a reason. The citrus from Calabria that perfumers keep reaching for.",
                readTime: "3 min",
                emoji: "🍋"
            ),
            FeedArticle(
                id: "a7",
                category: .guide,
                title: "How to Store Your Fragrances Properly",
                summary: "Heat, light and humidity are the enemies of your collection. Most people store their bottles wrong.",
                readTime: "2 min",
                emoji: "📦"
            ),
            FeedArticle(
                id: "a8",
                category: .ingredient,
                title: "Sandalwood — Mysore vs Australian",
                summary: "Not all sandalwood is equal. The difference between origins changes the character of the note completely.",
                readTime: "4 min",
                emoji: "🪵"
            )
        ]
    }

    @MainActor
    private func loadFragrances() async {
        isLoadingFragrances = true

        do {
            trending = try await PerfumeService.shared
                .searchPerfumes(query: "popular")
                .prefix(6)
                .map { FeedFragrance(
                    id: $0.id,
                    name: $0.name,
                    brand: $0.brand,
                    family: $0.family,
                    imageUrl: $0.imageUrl
                )}

            newReleases = try await PerfumeService.shared
                .searchPerfumes(query: "new 2025")
                .prefix(6)
                .map { FeedFragrance(
                    id: $0.id,
                    name: $0.name,
                    brand: $0.brand,
                    family: $0.family,
                    imageUrl: $0.imageUrl
                )}
        } catch {
            trending = []
            newReleases = []
        }

        isLoadingFragrances = false
    }
}
