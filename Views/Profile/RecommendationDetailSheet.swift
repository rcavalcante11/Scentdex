import SwiftUI
import SwiftData

struct RecommendationDetailSheet: View {

    // MARK: - Properties
    let fragrance: FragranceResult
    let ownedPerfumes: [Perfume]

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var added = false

    // MARK: - Computed
    private var commonNotes: [String] {
        let deckNotes = Set(ownedPerfumes.flatMap { $0.allNotes }
            .map { $0.lowercased() })
        let fragranceNotes = (fragrance.topNotes ?? []) +
                             (fragrance.middleNotes ?? []) +
                             (fragrance.baseNotes ?? [])
        return fragranceNotes.filter { deckNotes.contains($0.lowercased()) }
    }

    private var otherNotes: [String] {
        let common = Set(commonNotes.map { $0.lowercased() })
        let fragranceNotes = (fragrance.topNotes ?? []) +
                             (fragrance.middleNotes ?? []) +
                             (fragrance.baseNotes ?? [])
        return fragranceNotes.filter { !common.contains($0.lowercased()) }
    }

    private var resolvedFamily: FragranceFamily {
        let lower = fragrance.family.lowercased()
        switch lower {
        case "woody", "wood":                       return .woody
        case "floral", "white floral":              return .floral
        case "oriental", "amber", "warm spicy":     return .oriental
        case "fresh", "fruity":                     return .fresh
        case "citrus":                              return .citrus
        case "aquatic", "marine":                   return .aquatic
        case "gourmand", "sweet", "vanilla":        return .gourmand
        case "spicy", "fresh spicy":                return .spicy
        case "herbal", "green", "aromatic":         return .herbal
        default:                                    return .floral
        }
    }

    // MARK: - Body
    var body: some View {
        ZStack(alignment: .top) {
            // Background blurred
            if let imageUrl = fragrance.imageUrl,
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

            // Conteúdo
            VStack(alignment: .leading, spacing: 0) {

                // Handle
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.secondary.opacity(0.4))
                    .frame(width: 36, height: 4)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 12)
                    .padding(.bottom, 16)

                // Header com imagem
                HStack(spacing: 16) {
                    if let imageUrl = fragrance.imageUrl,
                       let url = URL(string: imageUrl) {
                        AsyncImage(url: url) { phase in
                            if case .success(let image) = phase {
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 80, height: 80)
                            } else {
                                bottlePlaceholder
                            }
                        }
                    } else {
                        bottlePlaceholder
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text(fragrance.name)
                            .font(.title2)
                            .fontWeight(.bold)

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

                            if let gender = fragrance.gender {
                                Text(gender)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)

                Divider()
                    .padding(.vertical, 16)

                // Common notes
                if !commonNotes.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Label("Matches your collection", systemImage: "checkmark.circle.fill")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(.green)

                        FlowLayout(spacing: 8) {
                            ForEach(commonNotes, id: \.self) { note in
                                Text(note)
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.green.opacity(0.12))
                                    .foregroundStyle(.green)
                                    .clipShape(Capsule())
                                    .overlay(
                                        Capsule()
                                            .stroke(Color.green.opacity(0.3), lineWidth: 1)
                                    )
                            }
                        }
                    }
                    .padding(.horizontal, 24)

                    Divider()
                        .padding(.vertical, 16)
                }

                // Other notes
                if !otherNotes.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Other notes")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)

                        FlowLayout(spacing: 8) {
                            ForEach(otherNotes, id: \.self) { note in
                                Text(note)
                                    .font(.caption)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.secondary.opacity(0.1))
                                    .foregroundStyle(.secondary)
                                    .clipShape(Capsule())
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                }

                Spacer()

                // Add button
                Button {
                    addToDeck()
                } label: {
                    HStack {
                        Image(systemName: added ? "checkmark" : "plus")
                        Text(added ? "Added to My Deck" : "Add to My Deck")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(added ? Color.green : Color.accentColor)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .disabled(added)
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
        }
    }

    // MARK: - Placeholder
    private var bottlePlaceholder: some View {
        ZStack {
            resolvedFamily.color.opacity(0.1)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            Image(systemName: "flask")
                .font(.system(size: 28))
                .foregroundStyle(resolvedFamily.color.opacity(0.4))
        }
        .frame(width: 80, height: 80)
    }

    // MARK: - Intent
    private func addToDeck() {
        let perfume = Perfume(
            name: fragrance.name,
            brand: fragrance.brand,
            family: resolvedFamily,
            gender: mapGender(fragrance.gender ?? ""),
            topNotes: fragrance.topNotes ?? [],
            middleNotes: fragrance.middleNotes ?? [],
            baseNotes: fragrance.baseNotes ?? [],
            imageUrl: fragrance.imageUrl
        )
        modelContext.insert(perfume)

        withAnimation { added = true }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            dismiss()
        }
    }

    private func mapGender(_ raw: String) -> PerfumeGender {
        switch raw.lowercased() {
        case "men", "masculine":   return .forMen
        case "women", "feminine":  return .forWomen
        default:                   return .forWomenAndMen
        }
    }
}
