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

    // MARK: - intent
    func delete(_ perfume: Perfume, context: ModelContext) {
        context.delete(perfume)
    }
}
