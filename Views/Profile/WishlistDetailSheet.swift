import SwiftUI
import SwiftData

/// Vista de detalhe para perfumes da Wishlist, no mesmo estilo visual do
/// RecommendationDetailSheet (match %, notas, botão "Add to Deck"), em vez
/// do PerfumeDetailView normal usado pela Collection.
///
/// Diferença chave: o RecommendationDetailSheet recebe um FragranceResult
/// vindo da API e cria um novo Perfume ao guardar. Aqui o Perfume já existe
/// em SwiftData (está na Wishlist) — "Add to My Deck" apenas muda
/// isWishlist para false, sem duplicar o registo.
struct WishlistDetailSheet: View {

    let perfume: Perfume
    /// Perfumes já na Collection (isWishlist == false), usados para
    /// calcular a percentagem de match de notas.
    let ownedPerfumes: [Perfume]

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    private enum SaveState {
        case none
        case addedToDeck
        case removed
    }

    @State private var saveState: SaveState = .none

    // MARK: - Computed
    private var allNotes: [String] {
        perfume.allNotes
    }

    private var commonNotes: [String] {
        let deckNotes = Set(ownedPerfumes.flatMap { $0.allNotes }.map { $0.lowercased() })
        return allNotes.filter { deckNotes.contains($0.lowercased()) }
    }

    private var otherNotes: [String] {
        let common = Set(commonNotes.map { $0.lowercased() })
        return allNotes.filter { !common.contains($0.lowercased()) }
    }

    private var matchPercentage: Int {
        guard !allNotes.isEmpty else { return 0 }
        return Int(Double(commonNotes.count) / Double(allNotes.count) * 100)
    }

    private var genderLabel: String {
        switch perfume.gender {
        case .forMen:         return "Men"
        case .forWomen:       return "Women"
        case .forWomenAndMen: return "Unisex"
        }
    }

    // MARK: - Body
    // Dividido em subviews explícitas (em vez de tudo numa única VStack
    // gigante) — o compilador tinha timeout a tentar type-check da
    // expressão inteira de uma vez.
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                handleBar
                headerSection
                Divider().padding(.vertical, 16)
                profileMatchSection
                notesSection
                actionButtons
            }
            .frame(maxWidth: .infinity)
        }
        .background { backgroundImage }
    }

    private var handleBar: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(Color.secondary.opacity(0.4))
            .frame(width: 36, height: 4)
            .frame(maxWidth: .infinity)
            .padding(.top, 12)
            .padding(.bottom, 16)
    }

    private var headerSection: some View {
        HStack(alignment: .center, spacing: 16) {
            bottleImage
                .frame(width: 90, height: 120)
                .background(perfume.family.color.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 6) {
                Text(perfume.name)
                    .font(.title2)
                    .fontWeight(.bold)
                    .fixedSize(horizontal: false, vertical: true)

                Text(perfume.brand)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                HStack(spacing: 8) {
                    Text(perfume.family.rawValue)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(perfume.family.color.opacity(0.15))
                        .foregroundStyle(perfume.family.color)
                        .clipShape(Capsule())

                    Text(genderLabel)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 24)
    }

    @ViewBuilder
    private var bottleImage: some View {
        if let imageUrl = perfume.imageUrl,
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

    @ViewBuilder
    private var profileMatchSection: some View {
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

                matchProgressBar

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
    }

    private var matchProgressBar: some View {
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
    }

    @ViewBuilder
    private var notesSection: some View {
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
            VStack(alignment: .leading, spacing: 12) {
                Text("Notes")
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
    }

    private var actionButtons: some View {
        VStack(spacing: 12) {
            // Add to Deck — move o Perfume já existente da Wishlist
            // para a Collection (isWishlist = false), sem duplicar.
            Button {
                addToDeck()
            } label: {
                HStack {
                    Image(systemName: saveState == .addedToDeck ? "checkmark" : "plus")
                    Text(saveState == .addedToDeck ? "Added to My Deck" : "Add to My Deck")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(saveState == .addedToDeck ? Color.green : Color.accentColor)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .disabled(saveState != .none)

            // Remove from Wishlist — substitui o "Save to Wishlist" do
            // RecommendationDetailSheet, que aqui não se aplica (o
            // perfume já está na wishlist).
            Button(role: .destructive) {
                removeFromWishlist()
            } label: {
                HStack {
                    Image(systemName: saveState == .removed ? "checkmark" : "trash")
                    Text(saveState == .removed ? "Removed" : "Remove from Wishlist")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.clear)
                .foregroundStyle(saveState == .removed ? Color.secondary : Color.red)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(saveState == .removed ? Color.secondary.opacity(0.3) : Color.red, lineWidth: 1.5)
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .disabled(saveState != .none)
        }
        .padding(.horizontal, 24)
        .padding(.top, 24)
        .padding(.bottom, 32)
    }

    @ViewBuilder
    private var backgroundImage: some View {
        if let imageUrl = perfume.imageUrl,
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
            .foregroundStyle(perfume.family.color.opacity(0.4))
    }

    // MARK: - Intent
    private func addToDeck() {
        perfume.isWishlist = false
        withAnimation { saveState = .addedToDeck }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { dismiss() }
    }

    private func removeFromWishlist() {
        modelContext.delete(perfume)
        withAnimation { saveState = .removed }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { dismiss() }
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
