import Foundation
import SwiftData
import Observation

enum FormMode {
    case create
    case edit(Perfume)
}

@Observable
class AddPerfumeViewModel {

    // MARK: - Properties
    var name: String = "" {
        didSet { searchIfNeeded() }
    }
    var brand: String = ""
    var family: FragranceFamily = .floral
    var gender: PerfumeGender = .forWomenAndMen
    var topNotes: String = "" 
    var middleNotes: String = ""
    var baseNotes: String = ""
    var accordsData: String? = nil

    // MARK: - Search
    var searchResults: [FragranceResult] = []
    var isSearching: Bool = false
    var selectedResult: FragranceResult? = nil
    var imageUrl: String? = nil
    
    // MARK: - Mode
    private let mode: FormMode
    private var searchTask: Task<Void, Never>?

    init(mode: FormMode = .create) {
        self.mode = mode
        if case .edit(let perfume) = mode {
            populateFields(from: perfume)
        }
    }

    // MARK: - Computed
    var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !brand.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var showSuggestions: Bool {
        !searchResults.isEmpty && selectedResult == nil
    }

    var navigationTitle: String {
        switch mode {
        case .create: return "Add Perfume"
        case .edit:   return "Edit Perfume"
        }
    }

    // MARK: - Intent
    func selectResult(_ result: FragranceResult) {
        selectedResult = result
        name   = result.name
        brand  = result.brand
        family = mapFamily(result.family)
        gender = mapGender(result.gender ?? "")
        imageUrl = result.bestImageUrl
        accordsData = result.accordsJSON

        // Usa notas separadas por camada se existirem, senão usa generalNotes em topNotes
        topNotes    = result.topNotes?.joined(separator: ", ")
                   ?? result.generalNotes?.joined(separator: ", ")
                   ?? ""
        middleNotes = result.middleNotes?.joined(separator: ", ") ?? ""
        baseNotes   = result.baseNotes?.joined(separator: ", ") ?? ""

        searchResults = []
        imageUrl = result.bestImageUrl
    }

    func save(context: ModelContext) {
        switch mode {
        case .create:
            let perfume = Perfume(
                name: name.trimmingCharacters(in: .whitespaces),
                brand: brand.trimmingCharacters(in: .whitespaces),
                family: family,
                gender: gender,
                topNotes: parsedNotes(from: topNotes),
                middleNotes: parsedNotes(from: middleNotes),
                baseNotes: parsedNotes(from: baseNotes),
                imageUrl: imageUrl,
                accordsData: accordsData
            )
            context.insert(perfume)

        case .edit(let perfume):
            perfume.name        = name.trimmingCharacters(in: .whitespaces)
            perfume.brand       = brand.trimmingCharacters(in: .whitespaces)
            perfume.family      = family
            perfume.gender      = gender
            perfume.topNotes    = parsedNotes(from: topNotes)
            perfume.middleNotes = parsedNotes(from: middleNotes)
            perfume.baseNotes   = parsedNotes(from: baseNotes)
        }
    }

    // MARK: - Private
    private func populateFields(from perfume: Perfume) {
        name        = perfume.name
        brand       = perfume.brand
        family      = perfume.family
        gender      = perfume.gender
        topNotes    = perfume.topNotes.joined(separator: ", ")
        middleNotes = perfume.middleNotes.joined(separator: ", ")
        baseNotes   = perfume.baseNotes.joined(separator: ", ")
    }

    private func searchIfNeeded() {
        guard name.count >= 2, selectedResult == nil else {
            searchResults = []
            return
        }
        searchTask?.cancel()
        searchTask = Task {
            try? await Task.sleep(nanoseconds: 500_000_000)
            guard !Task.isCancelled else { return }
            await search(query: name)
        }
    }

    @MainActor
    private func search(query: String) async {
        isSearching = true
        do {
            searchResults = try await PerfumeService.shared.searchPerfumes(query: query)
        } catch {
            searchResults = []
        }
        isSearching = false
    }

    private func parsedNotes(from string: String) -> [String] {
        string
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
    }

    // MARK: - Mapping (espelho do DeckView)
    private func mapFamily(_ raw: String) -> FragranceFamily {
        let lower = raw.lowercased().trimmingCharacters(in: .whitespaces)
        switch lower {
        case "woody", "wood", "oud", "sandalwood",
             "cedar", "vetiver", "patchouli":
            return .woody
        case "floral", "flower", "white floral",
             "yellow floral", "rose", "powdery",
             "musky", "aldehydic", "lactonic",
             "iris", "violet", "tuberose":
            return .floral
        case "oriental", "amber", "balsamic",
             "warm spicy", "tobacco", "leather",
             "smoky", "animalic", "incense", "resinous":
            return .oriental
        case "fresh", "fruity", "tropical",
             "light spicy", "soft spicy":
            return .fresh
        case "citrus", "citric", "lemon",
             "bergamot", "orange", "grapefruit":
            return .citrus
        case "aquatic", "marine", "water",
             "oceanic", "sea":
            return .aquatic
        case "gourmand", "sweet", "vanilla",
             "chocolate", "caramel", "coffee",
             "food", "honey":
            return .gourmand
        case "spicy", "spice", "fresh spicy",
             "cinnamon", "pepper", "cardamom":
            return .spicy
        case "herbal", "green", "fougere",
             "aromatic", "mossy", "earthy",
             "conifer", "lavender", "mint":
            return .herbal
        default:
            return .floral
        }
    }

    private func mapGender(_ raw: String) -> PerfumeGender {
        let lower = raw.lowercased().trimmingCharacters(in: .whitespaces)
        switch lower {
        case "men", "masculine", "for men":          return .forMen
        case "women", "feminine", "for women":       return .forWomen
        case "unisex", "for women and men", "both":  return .forWomenAndMen
        default:                                      return .forWomenAndMen
        }
    }
}
