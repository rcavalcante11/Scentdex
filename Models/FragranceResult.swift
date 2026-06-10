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
    let imageUrlStandard: String?
    let price: String?
    let mainAccords: [String: String]?

    // MARK: - Init interno
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
        self.imageUrlStandard = nil
        self.price = nil
        self.mainAccords = nil  // ← novo
    }

    // MARK: - Init da API Fragella
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name             = try container.decode(String.self, forKey: .name)
        brand            = try container.decode(String.self, forKey: .brand)
        gender           = try? container.decode(String.self, forKey: .gender)
        imageUrl         = try? container.decode(String.self, forKey: .imageUrl)
        imageUrlStandard = try? container.decode(String.self, forKey: .imageUrlStandard)
        price            = try? container.decode(String.self, forKey: .price)
        mainAccords      = try? container.decode([String: String].self, forKey: .mainAccords)  // ← novo

        let notesObj    = try? container.decode(NotesObject.self, forKey: .notes)
        topNotes        = notesObj?.top.map    { $0.name }
        middleNotes     = notesObj?.middle.map { $0.name }
        baseNotes       = notesObj?.base.map   { $0.name }
        generalNotes    = try? container.decode([String].self, forKey: .generalNotes)

        family = Self.extractDominantFamily(from: mainAccords)
        id     = "\(name)-\(brand)".lowercased().replacingOccurrences(of: " ", with: "-")
    }

    enum CodingKeys: String, CodingKey {
        case name            = "Name"
        case brand           = "Brand"
        case gender          = "Gender"
        case imageUrl        = "Image URL Transparent"
        case imageUrlStandard = "Image URL"
        case generalNotes    = "General Notes"
        case mainAccords     = "Main Accords Percentage"
        case notes           = "Notes"
        case price           = "Price"
    }

    // MARK: - Computed
    var bestImageUrl: String? {
        if let url = imageUrlStandard, !url.isEmpty { return url }
        if let url = imageUrl, !url.isEmpty { return url }
        return nil
    }

    // Converte mainAccords → JSON String para guardar no Perfume.accordsData
    var accordsJSON: String? {
        guard let accords = mainAccords, !accords.isEmpty else { return nil }
        guard let data = try? JSONEncoder().encode(accords),
              let json = String(data: data, encoding: .utf8)
        else { return nil }
        return json
    }

    // MARK: - Helpers
    private static func extractDominantFamily(from accords: [String: String]?) -> String {
        guard let accords = accords, !accords.isEmpty else { return "floral" }

        // Prioridade de família para desempate quando há múltiplos Dominant
        let familyPriority = [
            "woody", "oriental", "amber", "floral", "gourmand",
            "spicy", "fresh", "citrus", "aquatic", "herbal",
            "aromatic", "musky", "vanilla", "powdery", "fruity"
        ]

        let levels = ["Dominant", "Prominent", "Moderate", "Subtle"]
        for level in levels {
            let matches = accords.filter { $0.value == level }.keys.map { $0.lowercased() }
            if let winner = familyPriority.first(where: { matches.contains($0) }) {
                return winner
            }
            if let first = matches.first { return first }
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
        case top    = "Top"
        case middle = "Middle"
        case base   = "Base"
    }
}

private struct NoteItem: Codable {
    let name: String
}
