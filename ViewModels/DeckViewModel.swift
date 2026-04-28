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

    // MARK: - intent
    func confirmDelete(_ perfume: Perfume, context: ModelContext) {
        perfumeToDelete = perfume
        showingDeleteAlert = true
        
    }
    
    func delete(_ perfume: Perfume, context: ModelContext) {
        context.delete(perfume)
        perfumeToDelete = nil
        showingDeleteAlert = false
    }
}
