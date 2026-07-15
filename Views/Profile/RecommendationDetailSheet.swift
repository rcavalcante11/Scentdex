import SwiftUI
import SwiftData

struct RecommendationDetailSheet: View {

    let fragrance: FragranceResult
    let ownedPerfumes: [Perfume]

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    private enum SaveState {
        case none
        case deck
        case wishlist
    }

    @State private var saveState: SaveState = .none

    // MARK: - Computed
    private var commonNotes: [String] {
        let deckNotes = Set(ownedPerfumes.flatMap { $0.allNotes }.map { $0.lowercased() })
        return allNotes.filter { deckNotes.contains($0.lowercased()) }
    }

    private var otherNotes: [String] {
        let common = Set(commonNotes.map { $0.lowercased() })
        return allNotes.filter { !common.contains($0.lowercased()) }
    }

    private var allNotes: [String] {
        (fragrance.topNotes ?? []) +
        (fragrance.middleNotes ?? []) +
        (fragrance.baseNotes ?? [])
    }

    private var matchPercentage: Int {
        guard !allNotes.isEmpty else { return 0 }
        return Int(Double(commonNotes.count) / Double(allNotes.count) * 100)
    }

    private var resolvedFamily: FragranceFamily {
        let lower = fragrance.family.lowercased()
        switch lower {
        case "woody", "wood":                   return .woody
        case "floral", "white floral":          return .floral
        case "oriental", "amber", "warm spicy": return .oriental
        case "fresh", "fruity":                 return .fresh
        case "citrus":                          return .citrus
        case "aquatic", "marine":               return .aquatic
        case "gourmand", "sweet", "vanilla":    return .gourmand
        case "spicy", "fresh spicy":            return .spicy
        case "herbal", "green", "aromatic":     return .herbal
        default:                                return .floral
        }
    }

    /// Género final: a heurística pelo nome tem prioridade sobre o valor
    /// bruto da API, porque já confirmámos casos em que a Fragella devolve
    /// o género errado (ex: "Woman In Gold" marcado como "Men" na origem).
    private var resolvedGender: PerfumeGender {
        genderHeuristic(from: fragrance.name) ?? mapGender(fragrance.gender ?? "")
    }

    private var resolvedGenderLabel: String {
        switch resolvedGender {
        case .forMen:         return "Men"
        case .forWomen:       return "Women"
        case .forWomenAndMen: return "Unisex"
        }
    }

    /// Deteta sinais inequívocos de género no nome do perfume (ex: "Woman",
    /// "Homme", "For Her"). Devolve nil quando o nome não dá nenhum sinal
    /// claro ou dá sinais conflituosos, para não sobrepor a API sem motivo.
    private func genderHeuristic(from name: String) -> PerfumeGender? {
        let tokens = name.lowercased()
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { !$0.isEmpty }

        let femaleTokens: Set<String> = ["woman", "women", "femme", "her", "lady", "elle"]
        let maleTokens: Set<String> = ["man", "men", "homme", "him", "gentleman"]

        let hasFemale = tokens.contains { femaleTokens.contains($0) }
        let hasMale = tokens.contains { maleTokens.contains($0) }

        if hasFemale && !hasMale { return .forWomen }
        if hasMale && !hasFemale { return .forMen }
        return nil
    }

    // MARK: - Body
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {

                // Handle
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.secondary.opacity(0.4))
                    .frame(width: 36, height: 4)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 12)
                    .padding(.bottom, 16)

                // Header
                HStack(alignment: .center, spacing: 16) {
                    Group {
                        if let imageUrl = fragrance.bestImageUrl,
                           let url = URL(string: imageUrl) {
                            AsyncImage(url: url) { phase in
                                if case .success(let image) = phase {
                                    image.resizable().aspectRatio(contentMode: .fit)
                                } else {
                                    bottlePlaceholderContent
                                }
                            }
                        } else {
                            bottlePlaceholderContent
                        }
                    }
                    .frame(width: 90, height: 120)
                    .background(resolvedFamily.color.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                    VStack(alignment: .leading, spacing: 6) {
                        Text(fragrance.name)
                            .font(.title2)
                            .fontWeight(.bold)
                            .fixedSize(horizontal: false, vertical: true)

                        Text(fragrance.brand)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        HStack(spacing: 8) {
                            Text(resolvedFamily.rawValue)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(resolvedFamily.color.opacity(0.15))
                                .foregroundStyle(resolvedFamily.color)
                                .clipShape(Capsule())

                            if fragrance.gender != nil || genderHeuristic(from: fragrance.name) != nil {
                                Text(resolvedGenderLabel)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal, 24)

                Divider().padding(.vertical, 16)

                // Conexão com o perfil
                if !commonNotes.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {

                        HStack {
                            Text("Profile match")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Spacer()
                            Text("\(matchPercentage)%")
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundStyle(.green)
                        }

                        Text("Notes that match your collection")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        // Barra de progresso
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(Color.secondary.opacity(0.15))
                                    .frame(height: 4)
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(Color.green)
                                    .frame(width: geo.size.width * CGFloat(matchPercentage) / 100, height: 4)
                            }
                        }
                        .frame(height: 4)

                        FlowLayout(spacing: 16) {
                            ForEach(commonNotes, id: \.self) { note in
                                noteCircle(note, tint: .green)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(16)
                    .background(Color.green.opacity(0.06))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.green.opacity(0.2), lineWidth: 1)
                    )
                    .padding(.horizontal, 24)

                    if !otherNotes.isEmpty {
                        Divider().padding(.vertical, 16)
                    }
                }

                // Outras notas
                if !otherNotes.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Other notes")
                            .font(.subheadline)
                            .fontWeight(.semibold)

                        FlowLayout(spacing: 16) {
                            ForEach(otherNotes, id: \.self) { note in
                                noteCircle(note, tint: .secondary)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.horizontal, 24)
                } else if commonNotes.isEmpty && !allNotes.isEmpty {
                    // Sem notas em comum — mostra todas neutras
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Notas")
                            .font(.subheadline)
                            .fontWeight(.semibold)

                        FlowLayout(spacing: 16) {
                            ForEach(allNotes, id: \.self) { note in
                                noteCircle(note, tint: .secondary)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.horizontal, 24)
                }

                // Add to Deck button
                Button {
                    save(isWishlist: false)
                } label: {
                    HStack {
                        Image(systemName: saveState == .deck ? "checkmark" : "plus")
                        Text(saveState == .deck ? "Added to My Deck" : "Add to My Deck")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(saveState == .deck ? Color.green : Color.accentColor)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .disabled(saveState != .none)
                .padding(.horizontal, 24)
                .padding(.top, 24)

                // Save to Wishlist button
                Button {
                    save(isWishlist: true)
                } label: {
                    HStack {
                        Image(systemName: saveState == .wishlist ? "checkmark" : "heart")
                        Text(saveState == .wishlist ? "Saved to Wishlist" : "Save to Wishlist")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.clear)
                    .foregroundStyle(saveState == .wishlist ? .green : Color.accentColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(saveState == .wishlist ? Color.green : Color.accentColor, lineWidth: 1.5)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .disabled(saveState != .none)
                .padding(.horizontal, 24)
                .padding(.top, 12)
                .padding(.bottom, 32)
            }
            .frame(maxWidth: .infinity)
        }
        .background {
            if let imageUrl = fragrance.bestImageUrl,
               let url = URL(string: imageUrl) {
                AsyncImage(url: url) { phase in
                    if case .success(let image) = phase {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .blur(radius: 40)
                            .opacity(0.4)
                            .ignoresSafeArea()
                    }
                }
            }
        }
    }

    // MARK: - Note Circle
    private func noteCircle(_ note: String, tint: Color) -> some View {
        VStack(spacing: 4) {
            if let url = noteImageURL(for: note) {
                AsyncImage(url: url) { phase in
                    if case .success(let image) = phase {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 44, height: 44)
                            .background(tint.opacity(0.12))
                            .clipShape(Circle())
                    } else {
                        Circle()
                            .fill(tint.opacity(0.12))
                            .frame(width: 44, height: 44)
                    }
                }
            }
            Text(note)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .frame(width: 56)
                .lineLimit(2)
        }
    }

    // MARK: - Placeholder
    private var bottlePlaceholderContent: some View {
        Image(systemName: "flask")
            .font(.system(size: 28))
            .foregroundStyle(resolvedFamily.color.opacity(0.4))
    }

    // MARK: - Intent
    private func save(isWishlist: Bool) {
        let perfume = Perfume(
            name: fragrance.name,
            brand: fragrance.brand,
            family: resolvedFamily,
            gender: resolvedGender,
            topNotes: fragrance.topNotes ?? [],
            middleNotes: fragrance.middleNotes ?? [],
            baseNotes: fragrance.baseNotes ?? [],
            imageUrl: fragrance.bestImageUrl,
            accordsData: fragrance.accordsJSON,
            isWishlist: isWishlist
        )
        modelContext.insert(perfume)
        withAnimation { saveState = isWishlist ? .wishlist : .deck }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { dismiss() }
    }

    private func mapGender(_ raw: String) -> PerfumeGender {
        switch raw.lowercased() {
        case "men", "masculine":  return .forMen
        case "women", "feminine": return .forWomen
        default:                  return .forWomenAndMen
        }
    }

    private func noteImageURL(for note: String) -> URL? {
        let capitalized = note
            .split(separator: " ")
            .map { $0.prefix(1).uppercased() + $0.dropFirst() }
            .joined(separator: " ")
        let encoded = capitalized
            .addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? capitalized
        return URL(string: "https://cdn.fragella.com/note_images/\(encoded).png")
    }
}
