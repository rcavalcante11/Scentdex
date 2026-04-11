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

    // MARK: - Search
    var searchResults: [FragranceResult] = []
    var isSearching: Bool = false
    var selectedResult: FragranceResult? = nil

    // MARK: - Mode
    private let mode: FormMode

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
        name = result.name
        brand = result.brand
        family = FragranceFamily(rawValue: result.family.capitalized) ?? .floral
        gender = PerfumeGender(rawValue: result.gender ?? "") ?? .forWomenAndMen
        topNotes = result.topNotes?.joined(separator: ", ") ?? ""
        middleNotes = result.middleNotes?.joined(separator: ", ") ?? ""
        baseNotes = result.baseNotes?.joined(separator: ", ") ?? ""
        searchResults = []
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
                baseNotes: parsedNotes(from: baseNotes)
            )
            context.insert(perfume)

        case .edit(let perfume):
            perfume.name   = name.trimmingCharacters(in: .whitespaces)
            perfume.brand  = brand.trimmingCharacters(in: .whitespaces)
            perfume.family = family
            perfume.gender = gender
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
        Task {
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
}
