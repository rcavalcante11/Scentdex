import Foundation

struct FragranceResult: Decodable, Identifiable {
    let id: String
    let name: String
    let brand: String
    let family: String
    let generalNotes: [String]?
    let topNotes: [String]?
    let middleNotes: [String]?
    let baseNotes: [String]?
    let gender: String?
    let imageUrl: String?

    // MARK: - Init interno (mock data, RecommendationViewModel, etc.)
    init(id: String, name: String, brand: String, family: String,
         topNotes: [String]? = nil, middleNotes: [String]? = nil,
         baseNotes: [String]? = nil, gender: String? = nil, imageUrl: String? = nil) {
        self.id = id
        self.name = name
        self.brand = brand
        self.family = family
        self.topNotes = topNotes
        self.middleNotes = middleNotes
        self.baseNotes = baseNotes
        self.generalNotes = (topNotes ?? []) + (middleNotes ?? []) + (baseNotes ?? [])
        self.gender = gender
        self.imageUrl = imageUrl
    }

    // MARK: - Init da API Fragella
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name     = try container.decode(String.self, forKey: .name)
        brand    = try container.decode(String.self, forKey: .brand)
        gender   = try? container.decode(String.self, forKey: .gender)
        imageUrl = try? container.decode(String.self, forKey: .imageUrl)

        // Notas separadas por camada
        let notesObj = try? container.decode(NotesObject.self, forKey: .notes)
        topNotes    = notesObj?.top.map    { $0.name }
        middleNotes = notesObj?.middle.map { $0.name }
        baseNotes   = notesObj?.base.map   { $0.name }

        // General Notes como fallback
        generalNotes = try? container.decode([String].self, forKey: .generalNotes)

        // Família a partir de Main Accords Percentage
        let accords = try? container.decode([String: String].self, forKey: .mainAccords)
        family = Self.extractDominantFamily(from: accords)

        id = "\(name)-\(brand)".lowercased().replacingOccurrences(of: " ", with: "-")
    }

    enum CodingKeys: String, CodingKey {
        case name         = "Name"
        case brand        = "Brand"
        case gender       = "Gender"
        case imageUrl     = "Image URL Transparent"
        case generalNotes = "General Notes"
        case mainAccords  = "Main Accords Percentage"
        case notes        = "Notes"
    }

    // MARK: - Helpers
    private static func extractDominantFamily(from accords: [String: String]?) -> String {
        guard let accords = accords, !accords.isEmpty else { return "floral" }
        let priority = ["Dominant", "Prominent", "Moderate", "Subtle"]
        for level in priority {
            if let match = accords.first(where: { $0.value == level }) {
                return match.key.lowercased()
            }
        }
        return accords.keys.first?.lowercased() ?? "floral"
    }
}

// MARK: - Notes parsing
private struct NotesObject: Codable {
    let top: [NoteItem]
    let middle: [NoteItem]
    let base: [NoteItem]

    enum CodingKeys: String, CodingKey {
        case top = "Top"
        case middle = "Middle"
        case base = "Base"
    }
}

private struct NoteItem: Codable {
    let name: String
}
