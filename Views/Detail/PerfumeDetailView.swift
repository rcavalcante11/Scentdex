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
            Section("Details") {
                LabeledContent("Brand", value: perfume.brand)
                LabeledContent("Family", value: perfume.family.rawValue)
                LabeledContent("Gender", value: perfume.gender.rawValue)
                LabeledContent("Added", value: perfume.dateAdded.formatted(date: .abbreviated, time: .omitted))
            }

            if !allNotesCombined.isEmpty {
                if hasLayeredNotes {
                    // Opção B — notas separadas por camada (adicionadas manualmente)
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
                    // Notas da API — uma secção única
                    Section("Notes") {
                        notePills(allNotesCombined, color: perfume.family.color)
                    }
                }
            }
        }
        .navigationTitle(perfume.name)
        .navigationBarTitleDisplayMode(.large)
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

    // MARK: - Helpers
    private func notePills(_ notes: [String], color: Color) -> some View {
        FlowLayout(spacing: 8) {
            ForEach(notes, id: \.self) { note in
                Text(note)
                    .font(.caption)
                    .fontWeight(.medium)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(color.opacity(0.15))
                    .foregroundStyle(color)
                    .clipShape(Capsule())
                    .overlay(
                        Capsule()
                            .stroke(color.opacity(0.3), lineWidth: 1)
                    )
            }
        }
        .padding(.vertical, 4)
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
