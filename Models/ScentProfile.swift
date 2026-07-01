import Foundation

// MARK: - Accord Score
struct AccordScore {
    let name: String
    let score: Double
    let family: FragranceFamily
}

// MARK: - ScentProfile
struct ScentProfile {

    // MARK: - Properties
    let dominantFamily: FragranceFamily
    let secondFamily: FragranceFamily?
    let topNotes: [String]
    let familyDistribution: [FragranceFamily: Int]
    let familyScores: [FragranceFamily: Double]   // hybrid score por família
    let topAccords: [AccordScore]                 // top 8 acordes raw

    // MARK: - Computed

    // Label evocativo — "Heavy Oriental", "Aromatic Fresh", etc.
    var accordLabel: String {
        let sorted = familyScores.sorted { $0.value > $1.value }
        let first = sorted.first?.key ?? dominantFamily
        let second = sorted.count > 1 ? sorted[1].key : nil
        return Self.labelFor(dominant: first, second: second)
    }


    var profileTitle: String { accordLabel }

 
    var profileDescription: String {
        let names = topAccords.prefix(3).map { $0.name }.joined(separator: ", ")
        return "Your collection is defined by \(names). A profile built with intention."
    }



    // MARK: - Factory
    static func calculate(from perfumes: [Perfume]) -> ScentProfile? {
        guard !perfumes.isEmpty else { return nil }

        // 1. Acumula pontos por acorde em toda a colecção
        var accordSum: [String: Double] = [:]
        var accordMax: [String: Double] = [:]

        for perfume in perfumes {
            for (accord, level) in perfume.accords {
                let pts = levelPoints(level)
                let key = accord.lowercased().trimmingCharacters(in: .whitespaces)
                accordSum[key, default: 0] += pts
                accordMax[key] = max(accordMax[key, default: 0], pts)
            }
        }

        // 2. Mapeia acordes → famílias e aplica fórmula híbrida
        //    score = soma_ponderada + bónus_acorde_dominante
        var familySum: [FragranceFamily: Double] = [:]
        var familyBonus: [FragranceFamily: Double] = [:]

        for (accord, sum) in accordSum {
            let family = mapAccordToFamily(accord)
            familySum[family, default: 0] += sum
            let bonus = accordMax[accord, default: 0]
            familyBonus[family] = max(familyBonus[family, default: 0], bonus)
        }

        var familyScores: [FragranceFamily: Double] = [:]
        for (family, sum) in familySum {
            familyScores[family] = sum + (familyBonus[family, default: 0])
        }

        // 3. Famílias dominantes
        let sortedFamilies = familyScores.sorted { $0.value > $1.value }
        guard let dominant = sortedFamilies.first else { return nil }
        let second = sortedFamilies.count > 1 ? sortedFamilies[1].key : nil

        // 4. Top 8 acordes para o Aura Fingerprint
        let topAccords = accordSum
            .sorted { $0.value > $1.value }
            .prefix(8)
            .map { AccordScore(name: $0.key, score: $0.value, family: mapAccordToFamily($0.key)) }

        // 5. Distribuição por família (mantida para compatibilidade de UI)
        var familyCount: [FragranceFamily: Int] = [:]
        for perfume in perfumes {
            familyCount[perfume.family, default: 0] += 1
        }

        // 6. Top 10 notas mais frequentes
        var noteCount: [String: Int] = [:]
        for perfume in perfumes {
            for note in perfume.allNotes {
                noteCount[note.lowercased(), default: 0] += 1
            }
        }
        let topNotes = noteCount
            .sorted { $0.value > $1.value }
            .prefix(10)
            .map { $0.key.capitalized }

        return ScentProfile(
            dominantFamily: dominant.key,
            secondFamily: second,
            topNotes: topNotes,
            familyDistribution: familyCount,
            familyScores: familyScores,
            topAccords: Array(topAccords)
        )
    }

    // MARK: - Level → Points
    private static func levelPoints(_ level: String) -> Double {
        switch level.lowercased() {
        case "dominant":  return 3
        case "prominent": return 2
        case "moderate":  return 1
        default:          return 0
        }
    }

    // MARK: - Accord → Family
    static func mapAccordToFamily(_ accord: String) -> FragranceFamily {
        switch accord.lowercased().trimmingCharacters(in: .whitespaces) {
        case "woody", "wood", "oud", "sandalwood", "cedar", "vetiver",
             "patchouli", "guaiac wood", "teak wood", "agarwood":
            return .woody
        case "floral", "flower", "white floral", "yellow floral", "rose",
             "iris", "violet", "tuberose", "muguet", "jasmine":
            return .floral
        case "oriental", "amber", "balsamic", "warm spicy", "tobacco",
             "leather", "smoky", "animalic", "incense", "resinous":
            return .oriental
        case "fresh", "fruity", "tropical", "light spicy", "soft spicy", "terpenic":
            return .fresh
        case "citrus", "citric", "lemon", "bergamot", "orange",
             "grapefruit", "mandarin", "lime", "yuzu":
            return .citrus
        case "aquatic", "marine", "water", "oceanic", "sea", "salty", "mineral":
            return .aquatic
        case "gourmand", "sweet", "vanilla", "chocolate", "caramel",
             "coffee", "honey", "lactonic", "almond", "praline", "rum":
            return .gourmand
        case "spicy", "spice", "fresh spicy", "cinnamon", "pepper",
             "cardamom", "saffron", "clove", "nutmeg":
            return .spicy
        case "herbal", "green", "fougere", "aromatic", "mossy", "earthy",
             "conifer", "lavender", "mint", "aldehydic", "powdery", "musky", "hay":
            return .herbal
        default:
            return .herbal
        }
    }

    // MARK: - Label
    private static func labelFor(dominant: FragranceFamily, second: FragranceFamily?) -> String {
        switch (dominant, second) {
        case (.woody, .oriental), (.oriental, .woody):  return "Heavy Oriental"
        case (.woody, .floral), (.floral, .woody):      return "Floral Woody"
        case (.woody, .fresh), (.fresh, .woody):        return "Aromatic Woody"
        case (.woody, .spicy), (.spicy, .woody):        return "Spicy Woody"
        case (.woody, .gourmand), (.gourmand, .woody):  return "Warm Woody"
        case (.woody, .citrus), (.citrus, .woody):      return "Woody Citrus"
        case (.woody, .aquatic), (.aquatic, .woody):    return "Woody Marine"
        case (.woody, .herbal), (.herbal, .woody):      return "Aromatic Woody"
        case (.floral, .oriental), (.oriental, .floral): return "Floriental"
        case (.floral, .fresh), (.fresh, .floral):      return "Fresh Floral"
        case (.floral, .gourmand), (.gourmand, .floral): return "Gourmand Floral"
        case (.floral, .spicy), (.spicy, .floral):      return "Spicy Floral"
        case (.floral, .citrus), (.citrus, .floral):    return "Citrus Floral"
        case (.floral, .aquatic), (.aquatic, .floral):  return "Aquatic Floral"
        case (.floral, .herbal), (.herbal, .floral):    return "Botanical"
        case (.oriental, .fresh), (.fresh, .oriental):  return "Fresh Oriental"
        case (.oriental, .gourmand), (.gourmand, .oriental): return "Gourmand Oriental"
        case (.oriental, .spicy), (.spicy, .oriental):  return "Spicy Oriental"
        case (.oriental, .citrus), (.citrus, .oriental): return "Citrus Oriental"
        case (.oriental, .aquatic), (.aquatic, .oriental): return "Deep Marine"
        case (.oriental, .herbal), (.herbal, .oriental): return "Herbal Oriental"
        case (.fresh, .citrus), (.citrus, .fresh):      return "Aqua Fresh"
        case (.fresh, .aquatic), (.aquatic, .fresh):    return "Marine Fresh"
        case (.fresh, .spicy), (.spicy, .fresh):        return "Spicy Fresh"
        case (.fresh, .gourmand), (.gourmand, .fresh):  return "Fresh Gourmand"
        case (.fresh, .herbal), (.herbal, .fresh):      return "Aromatic Fresh"
        case (.citrus, .herbal), (.herbal, .citrus):    return "Aromatic Citrus"
        case (.citrus, .aquatic), (.aquatic, .citrus):  return "Marine Citrus"
        case (.citrus, .spicy), (.spicy, .citrus):      return "Spicy Citrus"
        case (.citrus, .gourmand), (.gourmand, .citrus): return "Sweet Citrus"
        case (.aquatic, .spicy), (.spicy, .aquatic):    return "Spicy Marine"
        case (.aquatic, .gourmand), (.gourmand, .aquatic): return "Warm Marine"
        case (.aquatic, .herbal), (.herbal, .aquatic):  return "Herbal Marine"
        case (.gourmand, .spicy), (.spicy, .gourmand):  return "Spicy Gourmand"
        case (.gourmand, .herbal), (.herbal, .gourmand): return "Herbal Gourmand"
        case (.spicy, .herbal), (.herbal, .spicy):      return "Aromatic Spicy"
        case (.woody, nil):    return "Pure Woody"
        case (.floral, nil):   return "Soliflore"
        case (.oriental, nil): return "Pure Oriental"
        case (.fresh, nil):    return "Aromatic Fresh"
        case (.citrus, nil):   return "Pure Citrus"
        case (.aquatic, nil):  return "Marine"
        case (.gourmand, nil): return "Pure Gourmand"
        case (.spicy, nil):    return "Aromatic Spicy"
        case (.herbal, nil):   return "Fougère"
        default:
            if let s = second { return "\(dominant.rawValue) \(s.rawValue)" }
            return dominant.rawValue
        }
    }
}
