

import Foundation
import SwiftData
// Note: Modelled as a class (not struct) as required by SwiftData.
// Notes stored as separate String arrays for MVP clarity.
// Refactor to [Note] with a NoteLayer enum if per-note
// metadata is needed in future.

@Model
class Perfume {
    
    var id: UUID
    var name: String
    var brand: String
    var family: FragranceFamily
    var topNotes: [String]
    var middleNotes: [String]
    var baseNotes: [String]
    var dateAdded: Date
    
    
    init(
        id: UUID = UUID(),
        name: String,
        brand: String,
        family: FragranceFamily,
        topNotes: [String] = [],
        middleNotes: [String] = [],
        baseNotes: [String] = [],
        dateAdded: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.brand = brand
        self.family = family
        self.topNotes = topNotes
        self.middleNotes = middleNotes
        self.baseNotes = baseNotes
        self.dateAdded = dateAdded
    }

    var allNotes: [String] {
           topNotes + middleNotes + baseNotes
       }
}
