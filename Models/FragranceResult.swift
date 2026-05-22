import Foundation

struct FragranceResult: Codable, Identifiable {
    let id: String
    let name: String
    let brand: String
    let family: String
    let generalNotes: [String]?
    let gender: String?
    let imageUrl: String?

    // Init para uso interno
    init(id: String, name: String, brand: String, family: String,
         topNotes: [String]? = nil, middleNotes: [String]? = nil,
         baseNotes: [String]? = nil, gender: String? = nil, imageUrl: String? = nil) {
        self.id = id
        self.name = name
        self.brand = brand
        self.family = family
        self.generalNotes = (topNotes ?? []) + (middleNotes ?? []) + (baseNotes ?? [])
        self.gender = gender
        self.imageUrl = imageUrl
    }

    // Init para decode da API
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name         = try container.decode(String.self, forKey: .name)
        brand        = try container.decode(String.self, forKey: .brand)
        family       = (try? container.decode(String.self, forKey: .family)) ?? ""
        generalNotes = try? container.decode([String].self, forKey: .generalNotes)
        gender       = try? container.decode(String.self, forKey: .gender)
        imageUrl     = try? container.decode(String.self, forKey: .imageUrl)
        id = "\(name)-\(brand)".lowercased().replacingOccurrences(of: " ", with: "-")
    }

    enum CodingKeys: String, CodingKey {
        case name         = "Name"
        case brand        = "Brand"
        case family       = "Family"
        case generalNotes = "General Notes"
        case gender       = "Gender"
        case imageUrl     = "Image URL Transparent"
    }

    // Compatibilidade com código existente
    var topNotes: [String]? { generalNotes }
    var middleNotes: [String]? { nil }
    var baseNotes: [String]? { nil }
}
