//
//  FragranceResult.swift
//  Scentdex
//
//  Created by macbook on 01/04/2026.
//

import Foundation

// Representa um perfume vindo da Fragella API
struct FragranceResult: Codable, Identifiable {
    let id: String
    let name: String
    let brand: String
    let family: String
    let topNotes: [String]?
    let middleNotes: [String]?
    let baseNotes: [String]?
    let gender: String?
    let imageUrl: String?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case brand
        case family
        case topNotes     = "top_notes"
        case middleNotes  = "middle_notes"
        case baseNotes    = "base_notes"
        case gender
        case imageUrl     = "image_url"
    }
}

