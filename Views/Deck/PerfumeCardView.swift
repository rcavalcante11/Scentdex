import SwiftUI
import SwiftData

struct PerfumeCardView: View {
    
    // MARK: - Properties
    let perfume: Perfume
    
    // MARK: - Body
    var body: some View {
        
        Group {
            if let imageUrl = perfume.imageUrl,
               let url = URL(string: imageUrl) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .empty:
                        imagePlaceholder
                    case .failure:
                        imagePlaceholder
                    @unknown default:
                        imagePlaceholder
                    }
                }
            } else {
                imagePlaceholder
            }
        }
        .frame(height: 120)
        .clipped()
        
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(perfume.name)
                        .font(.headline)
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                    Text(perfume.brand)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                
                Text(perfume.family.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(perfume.family.color.opacity(0.2))
                    .foregroundStyle(perfume.family.color)
                    .clipShape(Capsule())
            }
            .padding(12)
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 2)
    }
    private var imagePlaceholder: some View {
        ZStack {
            Rectangle()
                .fill(perfume.family.color.opacity(0.1))
            Image(systemName: "flask")
                .font(.system(size: 32))
                .foregroundStyle(perfume.family.color.opacity(0.4))
        }
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
