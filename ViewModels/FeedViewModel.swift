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
        await loadArticles()
        await loadFragrances()
    }

    // MARK: - Private
    @MainActor
    private func loadArticles() async {
        let rssURLs = [
            "https://www.basenotes.net/feed/",
               "https://www.nowsmellthis.com/feed/",
               "https://www.fragrantica.com/news/"
        ]

        var fetchedArticles: [FeedArticle] = []

        for urlString in rssURLs {
            guard let url = URL(string: urlString) else { continue }

            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                let parsed = RSSParser.parse(data: data)
                fetchedArticles.append(contentsOf: parsed.prefix(4).map { item in
                    let category = categorise(title: item.title)
                    return FeedArticle(
                        id: item.guid ?? UUID().uuidString,
                        category: category,
                        title: item.title,
                        summary: item.description.strippingHTML(),
                        readTime: estimateReadTime(from: item.description),
                        emoji: emoji(for: category),
                        url: URL(string: item.link ?? "")
                    )
                })
            } catch {
                print("❌ RSS failed for \(urlString): \(error)")
                continue
            }
            
        }
        print("📰 Fetched \(fetchedArticles.count) articles from RSS")
        articles = fetchedArticles.isEmpty ? localArticles() : fetchedArticles
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

    // MARK: - Helpers
    private func categorise(title: String) -> FeedCategory {
        let lower = title.lowercased()
        if lower.contains("review") || lower.contains("guide") { return .guide }
        if lower.contains("launch") || lower.contains("new") || lower.contains("release") { return .news }
        if lower.contains("ingredient") || lower.contains("note") || lower.contains("oud") || lower.contains("musk") { return .ingredient }
        return .tip
    }

    private func emoji(for category: FeedCategory) -> String {
        switch category {
        case .tip:        return "💡"
        case .guide:      return "📖"
        case .ingredient: return "🌿"
        case .news:       return "✨"
        }
    }

    private func estimateReadTime(from text: String) -> String {
        let wordCount = text.split(separator: " ").count
        let minutes = max(1, wordCount / 200)
        return "\(minutes) min"
    }

    private func localArticles() -> [FeedArticle] {
        [
            FeedArticle(id: "a1", category: .guide, title: "EDP vs EDT — What Actually Changes", summary: "Concentration affects more than just longevity. It changes the character of a fragrance entirely.", readTime: "3 min", emoji: "🧪", url: nil),
            FeedArticle(id: "a2", category: .tip, title: "The Right Way to Apply Fragrance", summary: "Pulse points matter — but the technique is more nuanced than most guides suggest.", readTime: "2 min", emoji: "💡", url: nil),
            FeedArticle(id: "a3", category: .ingredient, title: "What Is Oud — And Why Is It Everywhere", summary: "Agarwood is one of the most expensive raw materials in perfumery.", readTime: "4 min", emoji: "🌿", url: nil),
            FeedArticle(id: "a4", category: .tip, title: "Why Your Perfume Smells Different on Others", summary: "Skin chemistry, pH and diet all affect how a fragrance develops.", readTime: "3 min", emoji: "🔬", url: nil),
            FeedArticle(id: "a5", category: .guide, title: "Building a Capsule Fragrance Wardrobe", summary: "You don't need 30 bottles. Five well-chosen fragrances can cover every occasion.", readTime: "5 min", emoji: "👔", url: nil),
            FeedArticle(id: "a6", category: .ingredient, title: "Bergamot — The Note That Starts Almost Everything", summary: "It's in hundreds of fragrances for a reason.", readTime: "3 min", emoji: "🍋", url: nil)
        ]
    }
}

// MARK: - RSS Parser
private struct RSSItem {
    var title: String = ""
    var description: String = ""
    var link: String? = nil
    var guid: String? = nil
}

private class RSSParser: NSObject, XMLParserDelegate {

    private var items: [RSSItem] = []
    private var currentItem: RSSItem?
    private var currentElement = ""
    private var currentText = ""

    static func parse(data: Data) -> [RSSItem] {
        let delegate = RSSParser()
        let parser = XMLParser(data: data)
        parser.delegate = delegate
        parser.parse()
        return delegate.items
    }

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String] = [:]) {
        currentElement = elementName
        currentText = ""
        if elementName == "item" {
            currentItem = RSSItem()
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        currentText += string
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        guard var item = currentItem else { return }
        switch elementName {
        case "title":       item.title = currentText.trimmingCharacters(in: .whitespacesAndNewlines)
        case "description": item.description = currentText.trimmingCharacters(in: .whitespacesAndNewlines)
        case "link":        item.link = currentText.trimmingCharacters(in: .whitespacesAndNewlines)
        case "guid":        item.guid = currentText.trimmingCharacters(in: .whitespacesAndNewlines)
        case "item":
            if !item.title.isEmpty { items.append(item) }
            currentItem = nil
        default: break
        }
        currentItem = item
    }
}

// MARK: - String Extension
private extension String {
    func strippingHTML() -> String {
        guard let data = self.data(using: .utf8) else { return self }
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        let attributed = try? NSAttributedString(data: data, options: options, documentAttributes: nil)
        return attributed?.string.trimmingCharacters(in: .whitespacesAndNewlines) ?? self
    }
}
