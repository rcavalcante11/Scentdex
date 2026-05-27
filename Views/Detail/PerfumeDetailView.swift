import SwiftUI
import SwiftData

struct PerfumeDetailView: View {

    // MARK: - Properties
    let perfume: Perfume
    @State private var showingEdit = false

    // MARK: - Computed
    private var hasLayeredNotes: Bool {
        !perfume.middleNotes.isEmpty || !perfume.baseNotes.isEmpty
    }

    private var allNotesCombined: [String] {
        perfume.topNotes + perfume.middleNotes + perfume.baseNotes
    }

    // MARK: - Body
    var body: some View {
        List {
            // Header com imagem dentro da lista
            ZStack {
                if let imageUrl = perfume.imageUrl,
                   let url = URL(string: imageUrl) {
                    AsyncImage(url: url) { phase in
                        if case .success(let image) = phase {
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .blur(radius: 40)
                                .opacity(0.5)
                                .clipped()
                        }
                    }
                }

                VStack(spacing: 10) {
                    if let imageUrl = perfume.imageUrl,
                       let url = URL(string: imageUrl) {
                        AsyncImage(url: url) { phase in
                            if case .success(let image) = phase {
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height: 140)
                            } else {
                                bottlePlaceholder
                            }
                        }
                    } else {
                        bottlePlaceholder
                    }

                    Text(perfume.family.rawValue)
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(perfume.family.color.opacity(0.3))
                        .foregroundStyle(perfume.family.color)
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .stroke(perfume.family.color.opacity(0.5), lineWidth: 1)
                        )
                }
                .padding(.vertical, 20)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 220)
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.black)
            .listRowSeparator(.hidden)

            Section("Details") {
                LabeledContent("Brand", value: perfume.brand)
                LabeledContent("Family", value: perfume.family.rawValue)
                LabeledContent("Gender", value: perfume.gender.rawValue)
                LabeledContent("Added", value: perfume.dateAdded.formatted(date: .abbreviated, time: .omitted))
            }

            if !allNotesCombined.isEmpty {
                if hasLayeredNotes {
                    if !perfume.topNotes.isEmpty {
                        Section("Top Notes") {
                            notePills(perfume.topNotes, color: .mint)
                        }
                    }
                    if !perfume.middleNotes.isEmpty {
                        Section("Middle Notes") {
                            notePills(perfume.middleNotes, color: .orange)
                        }
                    }
                    if !perfume.baseNotes.isEmpty {
                        Section("Base Notes") {
                            notePills(perfume.baseNotes, color: .brown)
                        }
                    }
                } else {
                    Section("Notes") {
                        notePills(allNotesCombined, color: perfume.family.color)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(perfume.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Edit") {
                    showingEdit = true
                }
            }
        }
        .sheet(isPresented: $showingEdit) {
            AddPerfumeView(mode: .edit(perfume))
        }
    }

    // MARK: - Placeholder
    private var bottlePlaceholder: some View {
        ZStack {
            perfume.family.color.opacity(0.1)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            Image(systemName: "flask")
                .font(.system(size: 48))
                .foregroundStyle(perfume.family.color.opacity(0.4))
        }
        .frame(width: 100, height: 120)
    }

    // MARK: - Note Pills
    private func notePills(_ notes: [String], color: Color) -> some View {
        FlowLayout(spacing: 8) {
            ForEach(notes, id: \.self) { note in
                notePill(note, color: color)
            }
        }
        .padding(.vertical, 4)
    }

    private func notePill(_ note: String, color: Color) -> some View {
        VStack(spacing: 6) {
            // Imagem circular
            if let url = noteImageURL(for: note) {
                AsyncImage(url: url) { phase in
                    if case .success(let image) = phase {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 54, height: 54)
                            .background(color.opacity(0.12))
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(color.opacity(0.25), lineWidth: 1)
                            )
                    } else {
                        Circle()
                            .fill(color.opacity(0.12))
                            .frame(width: 54, height: 54)
                            .overlay(
                                Circle()
                                    .stroke(color.opacity(0.25), lineWidth: 1)
                            )
                    }
                }
            } else {
                Circle()
                    .fill(color.opacity(0.12))
                    .frame(width: 54, height: 54)
            }

            // Nome da nota
            Text(note)
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundStyle(color)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(width: 64)
        }
        .padding(.vertical, 4)
    }

    // MARK: - Note Image URL
    private func noteImageURL(for note: String) -> URL? {
        // Capitaliza cada palavra e faz URL encoding
        // Ex: "clary sage" → "Clary%20Sage.png"
        let capitalized = note
            .split(separator: " ")
            .map { $0.prefix(1).uppercased() + $0.dropFirst() }
            .joined(separator: " ")

        let encoded = capitalized
            .addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)
            ?? capitalized

        return URL(string: "https://cdn.fragella.com/note_images/\(encoded).png")
    }
}

#Preview {
    NavigationStack {
        PerfumeDetailView(perfume: Perfume(
            name: "Bleu de Chanel",
            brand: "Chanel",
            family: .woody,
            gender: .forMen,
            topNotes: ["Bergamot", "Lemon"],
            middleNotes: ["Ginger", "Nutmeg"],
            baseNotes: ["Sandalwood", "Cedar"]
        ))
    }
    .modelContainer(for: Perfume.self, inMemory: true)
}
