import Foundation
import SwiftData

@Model
class Perfume {

    var id: UUID
    var name: String
    var brand: String
    var family: FragranceFamily
    var gender: PerfumeGender
    var topNotes: [String]
    var middleNotes: [String]
    var baseNotes: [String]
    var dateAdded: Date
    var imageUrl: String?
    var accordsData: String?  // JSON: {"woody":"Dominant","oud":"Prominent",...}
    var isWishlist: Bool = false

    init(
        id: UUID = UUID(),
        name: String,
        brand: String,
        family: FragranceFamily,
        gender: PerfumeGender = .forWomenAndMen,
        topNotes: [String] = [],
        middleNotes: [String] = [],
        baseNotes: [String] = [],
        dateAdded: Date = Date(),
        imageUrl: String? = nil,
        accordsData: String? = nil,
        isWishlist: Bool = false
    )
    
    {
        self.id = id
        self.name = name
        self.brand = brand
        self.family = family
        self.gender = gender
        self.topNotes = topNotes
        self.middleNotes = middleNotes
        self.baseNotes = baseNotes
        self.dateAdded = dateAdded
        self.imageUrl = imageUrl
        self.accordsData = accordsData
        self.isWishlist = isWishlist
    }

    var allNotes: [String] {
        topNotes + middleNotes + baseNotes
    }

    // Converte accordsData JSON → [String: String]
    var accords: [String: String] {
        guard let data = accordsData?.data(using: .utf8),
              let dict = try? JSONDecoder().decode([String: String].self, from: data)
        else { return [:] }
        return dict
    }

    // MARK: - Sample Data
    static var sampleData: [Perfume] {
        [
            Perfume(
                name: "Bleu de Chanel",
                brand: "Chanel",
                family: .woody,
                gender: .forMen,
                topNotes: ["Bergamot", "Lemon"],
                middleNotes: ["Ginger", "Nutmeg"],
                baseNotes: ["Sandalwood", "Cedar"],
                accordsData: "{\"woody\":\"Dominant\",\"aromatic\":\"Prominent\",\"fresh\":\"Moderate\"}"
            ),
            Perfume(
                name: "Sauvage",
                brand: "Dior",
                family: .fresh,
                gender: .forMen,
                topNotes: ["Bergamot"],
                middleNotes: ["Pepper", "Lavender"],
                baseNotes: ["Ambroxan", "Cedar"],
                accordsData: "{\"fresh spicy\":\"Dominant\",\"aromatic\":\"Prominent\",\"woody\":\"Moderate\"}"
            ),
            Perfume(
                name: "Black Opium",
                brand: "YSL",
                family: .oriental,
                gender: .forWomen,
                topNotes: ["Pink Pepper", "Orange Blossom"],
                middleNotes: ["Coffee", "Jasmine"],
                baseNotes: ["Vanilla", "Patchouli"],
                accordsData: "{\"sweet\":\"Dominant\",\"gourmand\":\"Dominant\",\"coffee\":\"Prominent\"}"
            ),
            Perfume(
                name: "Light Blue",
                brand: "Dolce & Gabbana",
                family: .citrus,
                gender: .forWomenAndMen,
                topNotes: ["Sicilian Lemon", "Apple"],
                middleNotes: ["Bamboo", "Jasmine"],
                baseNotes: ["Cedar", "Musk"],
                accordsData: "{\"citrus\":\"Dominant\",\"fresh\":\"Prominent\",\"musky\":\"Moderate\"}"
            )
        ]
    }
}

extension Perfume: nonisolated Identifiable {}
