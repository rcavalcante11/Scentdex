//
//  DeckViewModel.swift
//  Scentdex
//
//  Created by macbook on 21/03/2026.
//

import Foundation
import SwiftData
import Observation

@Observable
class DeckViewModel {

    // MARK: - Properties
    var perfumes: [Perfume] = []
    var perfumeToDelete: Perfume? = nil
    var showingDeleteAlert = false

    // MARK: - Search
    var apiSearchResults: [FragranceResult] = []
    var isSearchingAPI = false
    private var searchTask: Task<Void, Never>?

    // MARK: - Intent
    func confirmDelete(_ perfume: Perfume) {
        perfumeToDelete = perfume
        showingDeleteAlert = true
    }

    func delete(_ perfume: Perfume, context: ModelContext) {
        context.delete(perfume)
        perfumeToDelete = nil
        showingDeleteAlert = false
    }

    @MainActor
    func searchAPI(query: String) async {
        guard query.count >= 2 else {
            searchTask?.cancel()
            apiSearchResults = []
            return
        }

        searchTask?.cancel()

        searchTask = Task {
            try? await Task.sleep(nanoseconds: 500_000_000)
            guard !Task.isCancelled else { return }
            await performSearch(query: query)
        }
    }

    // MARK: - Private
    @MainActor
    private func performSearch(query: String) async {
        isSearchingAPI = true
        do {
            apiSearchResults = try await PerfumeService.shared.searchPerfumes(query: query)
        } catch {
            apiSearchResults = []
        }
        isSearchingAPI = false
    }
}
