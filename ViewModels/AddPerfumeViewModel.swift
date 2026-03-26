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
    var name: String = ""
    var brand: String = ""
    var family: FragranceFamily = .floral
    var topNotes: String = ""
    var middleNotes: String = ""
    var baseNotes: String = ""
    
    // MARK: - Computed
    var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !brand.trimmingCharacters(in: .whitespaces).isEmpty
        
    }
    
    //MARK - intent
    
    func savePerfume(context: ModelContext){
        let perfume = Perfume(
            name: name.trimmingCharacters(in: .whitespaces),
            brand: brand.trimmingCharacters(in: .whitespaces), family: family,
            topNotes: parsedNotes( from: topNotes),
            middleNotes: parsedNotes( from: middleNotes),
            baseNotes: parsedNotes( from: baseNotes),
        )
        context.insert(perfume)
    }
    
    // MARK: - Helpers
       private func parsedNotes(from string: String) -> [String] {
           string
               .split(separator: ",")
               .map { $0.trimmingCharacters(in: .whitespaces) }
               .filter { !$0.isEmpty }
       }
}
