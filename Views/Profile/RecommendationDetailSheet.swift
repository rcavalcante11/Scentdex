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

    private var allNotes: [String] {
        (fragrance.topNotes ?? []) +
        (fragrance.middleNotes ?? []) +
        (fragrance.baseNotes ?? [])
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
                        if let imageUrl = fragrance.imageUrl,
                           let url = URL(string: imageUrl) {
                            AsyncImage(url: url) { phase in
                                if case .success(let image) = phase {
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
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

                            if let gender = fragrance.gender {
                                Text(gender)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal, 24)

                Divider()
                    .padding(.vertical, 16)

                // Matches your collection
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
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.horizontal, 24)

                    Divider()
                        .padding(.vertical, 16)
                }

                // Notes com imagens circulares
                if !allNotes.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Notes")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)

                        FlowLayout(spacing: 16) {
                            ForEach(allNotes, id: \.self) { note in
                                VStack(spacing: 4) {
                                    if let url = noteImageURL(for: note) {
                                        AsyncImage(url: url) { phase in
                                            if case .success(let image) = phase {
                                                image
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .frame(width: 44, height: 44)
                                                    .background(Color.secondary.opacity(0.1))
                                                    .clipShape(Circle())
                                            } else {
                                                Circle()
                                                    .fill(Color.secondary.opacity(0.1))
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
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.horizontal, 24)
                }

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
                .padding(.top, 24)
                .padding(.bottom, 32)
            }
            .frame(maxWidth: .infinity)
        }
        .background {
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
        }
    }

    // MARK: - Placeholder
    private var bottlePlaceholderContent: some View {
        Image(systemName: "flask")
            .font(.system(size: 28))
            .foregroundStyle(resolvedFamily.color.opacity(0.4))
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
