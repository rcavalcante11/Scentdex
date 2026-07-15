import Foundation
import Observation
import UIKit

// MARK: - Models
struct FeedArticle: Identifiable {
    let id: String
    let category: FeedCategory
    let title: String
    let summary: String
    let readTime: String
    let emoji: String
    let url: URL?
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
    private(set) var trending: [FragranceResult] = []
    private(set) var newReleases: [FragranceResult] = []
    private(set) var isLoadingFragrances = false

    // MARK: - Intent
    func loadContent() async {
        await loadArticles()
        await loadFragrances()
    }

    // MARK: - Private
    @MainActor
    private func loadArticles() async {
        // Conteúdo editorial próprio, curado à mão — não depende de nenhuma
        // fonte externa (RSS, scraping, etc.), por isso é sempre estável.
        articles = mockArticles()
    }

    @MainActor
    private func loadFragrances() async {
        isLoadingFragrances = true
        do {
            trending = Array(
                try await PerfumeService.shared.searchPerfumes(query: "popular").prefix(6)
            )
            newReleases = Array(
                try await PerfumeService.shared.searchPerfumes(query: "new 2025").prefix(6)
            )
        } catch {
            trending = []
            newReleases = []
        }

        isLoadingFragrances = false
    }

    // MARK: - Editorial Content
    private func mockArticles() -> [FeedArticle] {
        [
            FeedArticle(
                id: "a1",
                category: .guide,
                title: "EDP vs EDT — What Actually Changes",
                summary: "Concentration affects more than just longevity. It changes the character of a fragrance entirely.",
                readTime: "3 min",
                emoji: "🧪",
                url: nil
            ),
            FeedArticle(
                id: "a2",
                category: .tip,
                title: "The Right Way to Apply Fragrance",
                summary: "Pulse points matter — but the technique is more nuanced than most guides suggest.",
                readTime: "2 min",
                emoji: "💡",
                url: nil
            ),
            FeedArticle(
                id: "a3",
                category: .ingredient,
                title: "What Is Oud — And Why Is It Everywhere",
                summary: "Agarwood is one of the most expensive raw materials in perfumery, and it's showing up in mainstream releases.",
                readTime: "4 min",
                emoji: "🌿",
                url: nil
            ),
            FeedArticle(
                id: "a4",
                category: .tip,
                title: "Why Your Perfume Smells Different on Others",
                summary: "Skin chemistry, pH and diet all affect how a fragrance develops once it's on you.",
                readTime: "3 min",
                emoji: "🔬",
                url: nil
            ),
            FeedArticle(
                id: "a5",
                category: .guide,
                title: "Building a Capsule Fragrance Wardrobe",
                summary: "You don't need 30 bottles. Five well-chosen fragrances can cover every occasion.",
                readTime: "5 min",
                emoji: "👔",
                url: nil
            ),
            FeedArticle(
                id: "a6",
                category: .ingredient,
                title: "Bergamot — The Note That Starts Almost Everything",
                summary: "It's in hundreds of fragrances for a reason: bright, versatile, and it plays well with nearly every other note.",
                readTime: "3 min",
                emoji: "🍋",
                url: nil
            ),
            FeedArticle(
                id: "a7",
                category: .news,
                title: "Niche Perfumery Is Having a Moment",
                summary: "Independent houses are pulling attention away from designer names, driven by a hunger for distinctive scents.",
                readTime: "4 min",
                emoji: "✨",
                url: nil
            ),
            FeedArticle(
                id: "a8",
                category: .guide,
                title: "How to Layer Fragrances Without Overdoing It",
                summary: "Layering can build a signature scent — or turn into a mess. Here's how to tell the difference.",
                readTime: "4 min",
                emoji: "🧴",
                url: nil
            ),
            FeedArticle(
                id: "a9",
                category: .ingredient,
                title: "Ambroxan — The Modern Musk Behind Your Favorite Scent",
                summary: "This one molecule shows up in half the fragrances released in the last decade. Here's why perfumers love it.",
                readTime: "3 min",
                emoji: "🧫",
                url: nil
            ),
            FeedArticle(
                id: "a10",
                category: .tip,
                title: "Storage Mistakes That Are Ruining Your Collection",
                summary: "Light, heat and humidity break down fragrance faster than most people realize.",
                readTime: "2 min",
                emoji: "📦",
                url: nil
            ),
            FeedArticle(
                id: "a11",
                category: .news,
                title: "Why Fragrance Houses Are Going Gender-Neutral",
                summary: "Unisex releases have moved from niche experiment to mainstream strategy across the industry.",
                readTime: "3 min",
                emoji: "🌍",
                url: nil
            ),
            FeedArticle(
                id: "a12",
                category: .guide,
                title: "Decoding Fragrance Pyramids: Top, Heart, Base",
                summary: "Every fragrance tells a story in three acts. Understanding the structure changes how you shop for scent.",
                readTime: "4 min",
                emoji: "📐",
                url: nil
            )
        ]
    }
}
