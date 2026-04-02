//
//  AddPerfumeViewModel.swift
//  Scentdex
//
//  Created by macbook on 25/03/2026.
//

import Foundation
import SwiftData
import Observation


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
    
    
    // MARK: - Search function
    var searchResults: [FragranceResult] = []
    var isSearching: Bool = false
    var selectedResult: FragranceResult? = nil
    
    
    
    // MARK: - Computed
    var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !brand.trimmingCharacters(in: .whitespaces).isEmpty
        
    }
    
    var showSuggestion: Bool {
        !searchResults.isEmpty && selectedResult == nil
    }
    
    //MARK - intent
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
    
    func savePerfume(context: ModelContext){
        let perfume = Perfume(
            name: name.trimmingCharacters(in: .whitespaces),
            brand: brand.trimmingCharacters(in: .whitespaces),
            family: family,
            gender: gender,
            topNotes: parsedNotes( from: topNotes),
            middleNotes: parsedNotes( from: middleNotes),
            baseNotes: parsedNotes( from: baseNotes),
            )
            context.insert(perfume)
        }
    
    // MARK: - Private
    
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
