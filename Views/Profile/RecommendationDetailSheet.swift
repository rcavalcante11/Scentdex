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
        return fragranceNotes
            .filter { deckNotes.contains($0.lowercased()) }
    }

    private var otherNotes: [String] {
        let common = Set(commonNotes.map { $0.lowercased() })
        let fragranceNotes = (fragrance.topNotes ?? []) +
                             (fragrance.middleNotes ?? []) +
                             (fragrance.baseNotes ?? [])
        return fragranceNotes
            .filter { !common.contains($0.lowercased()) }
    }

    private var familyColor: Color {
        switch fragrance.family.lowercased() {
        case "woody":    return .purple
        case "floral":   return .pink
        case "oriental": return .orange
        case "fresh":    return .mint
        case "citrus":   return .yellow
        case "aquatic":  return .blue
        case "gourmand": return .purple
        case "spicy":    return .red
        case "herbal":   return .green
        default:         return .gray
        }
    }

    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // Handle
            RoundedRectangle(cornerRadius: 2)
                .fill(Color.secondary.opacity(0.4))
                .frame(width: 36, height: 4)
                .frame(maxWidth: .infinity)
                .padding(.top, 12)
                .padding(.bottom, 16)

            // Header
            VStack(alignment: .leading, spacing: 6) {
                Text(fragrance.name)
                    .font(.title2)
                    .fontWeight(.bold)

                Text(fragrance.brand)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                HStack(spacing: 8) {
                    Text(fragrance.family.capitalized)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(familyColor.opacity(0.15))
                        .foregroundStyle(familyColor)
                        .clipShape(Capsule())

                    if let gender = fragrance.gender {
                        Text(gender)
                            .font(.caption)
                            .foregroundStyle(.secondary)
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

    // MARK: - Intent
    private func addToDeck() {
        let family = FragranceFamily(rawValue: fragrance.family.capitalized) ?? .floral
        let gender = PerfumeGender(rawValue: fragrance.gender ?? "") ?? .forWomenAndMen

        let perfume = Perfume(
            name: fragrance.name,
            brand: fragrance.brand,
            family: family,
            gender: gender,
            topNotes: fragrance.topNotes ?? [],
            middleNotes: fragrance.middleNotes ?? [],
            baseNotes: fragrance.baseNotes ?? []
        )
        modelContext.insert(perfume)

        withAnimation {
            added = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            dismiss()
        }
    }
}
