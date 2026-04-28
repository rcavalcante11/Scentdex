import SwiftUI
import SwiftData

struct PerfumeCardView: View {

    // MARK: - Properties
    let perfume: Perfume

    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(perfume.name)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Text(perfume.brand)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Text(perfume.family.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(perfume.family.color.opacity(0.2))
                    .foregroundStyle(perfume.family.color)
                    .clipShape(Capsule())
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 2)
    }
}

#Preview {
    PerfumeCardView(perfume: Perfume(
        name: "Bleu de Chanel",
        brand: "Chanel",
        family: .woody,
        gender: .forWomenAndMen,
        topNotes: ["Bergamot", "Lemon"],
        middleNotes: ["Ginger", "Nutmeg"],
        baseNotes: ["Sandalwood", "Cedar"]
    ))
    .padding()
    .modelContainer(for: Perfume.self, inMemory: true)
}
