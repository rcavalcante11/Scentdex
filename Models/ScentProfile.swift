//
//  ScentProfile.swift
//  Scentdex
//
//  Created by macbook on 27/03/2026.
//

import Foundation

struct ScentProfile {
    
    // MARK: - Properties
    let dominantFamily: FragranceFamily
    let secondFamily: FragranceFamily?
    let topNotes: [String]
    let familyDistribution: [FragranceFamily: Int]
    
    
    var profileTitle: String {
        if let second = secondFamily {
            return "\(dominantFamily.rawValue) & \(second.rawValue)"
        }
        return dominantFamily.rawValue
    }
    
    var profileDescription: String {
        switch dominantFamily {
        case .woody:
            return "You gravitate toward warm, grounding fragrances. Your collection speaks of depth, confidence and understated elegance."
        case .floral:
            return "Your collection blooms with romance and femininity. You appreciate beauty in its most natural and expressive form."
        case .oriental:
            return "Rich and intoxicating — your taste leans toward the exotic and sensual. Your fragrances leave a lasting impression."
        case .fresh:
            return "Clean, effortless and modern. Your collection reflects a love for crisp openings and light, airy compositions."
        case .citrus:
            return "Bright and energetic — your collection radiates optimism. You reach for fragrances that feel like sunshine."
        case .aquatic:
            return "Your collection evokes open water and freedom. Cool, clean and effortlessly modern."
        case .gourmand:
            return "Warm and indulgent — your collection is comforting and unique. You aren't afraid to wear something truly different."
        case .spicy:
            return "Bold and confident. Your fragrances command attention and leave a trail that's impossible to ignore."
        case .herbal:
            return "Natural and grounded — your collection reflects a love for the outdoors and aromatic complexity."
        }
    }

    var auraColors: [String] {
        switch dominantFamily {
        case .woody:     return ["#7C3AED", "#92400E"]
        case .floral:    return ["#DB2777", "#9D174D"]
        case .oriental:  return ["#D97706", "#92400E"]
        case .fresh:     return ["#0D9488", "#0369A1"]
        case .citrus:    return ["#D97706", "#65A30D"]
        case .aquatic:   return ["#0369A1", "#0D9488"]
        case .gourmand:  return ["#7C3AED", "#DB2777"]
        case .spicy:     return ["#DC2626", "#D97706"]
        case .herbal:    return ["#65A30D", "#0D9488"]
        }
    }
    
    // MARK: - Factory
    static func calculate(from perfumes: [Perfume]) -> ScentProfile? {
        guard !perfumes.isEmpty else { return nil }

        // Count family frequency
        var familyCount: [FragranceFamily: Int] = [:]
        for perfume in perfumes {
            familyCount[perfume.family, default: 0] += 1
        }

        // Sort by frequency
        let sorted = familyCount.sorted { $0.value > $1.value }
        guard let dominant = sorted.first else { return nil }

        let second = sorted.count > 1 ? sorted[1].key : nil

        // Count note frequency
        var noteCount: [String: Int] = [:]
        for perfume in perfumes {
            for note in perfume.allNotes {
                noteCount[note.lowercased(), default: 0] += 1
            }
        }

        // Top 3 most frequent notes
        let topNotes = noteCount
            .sorted { $0.value > $1.value }
            .prefix(3)
            .map { $0.key.capitalized }

        return ScentProfile(
            dominantFamily: dominant.key,
            secondFamily: second,
            topNotes: topNotes,
            familyDistribution: familyCount
        )
    }
    
    
}
