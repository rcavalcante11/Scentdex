import SwiftUI
import SwiftData

struct PerfumeCardView: View {

    // MARK: - Properties
    let perfume: Perfume

    // MARK: - Body
    var body: some View {
        ZStack(alignment: .bottom) {

            backgroundView

            LinearGradient(
                colors: [.clear, .black],
                startPoint: .center,
                endPoint: .bottom
            )

            VStack(alignment: .leading, spacing: 4) {
                Text(perfume.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .lineLimit(1)

                HStack {
                    Text(perfume.brand)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.75))

                    Spacer()

                    Text(perfume.family.rawValue)
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(perfume.family.color.opacity(0.85))
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                }
            }
            .padding(12)
        }
        .frame(height: 180)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
    }

    // MARK: - Helpers
    @ViewBuilder
    private var backgroundView: some View {
        if let imageUrl = perfume.imageUrl,
           let url = URL(string: imageUrl) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(8)
                case .empty, .failure:
                    familyBackground
                @unknown default:
                    familyBackground
                }
            }
        } else {
            familyBackground
        }
    }

    private var familyBackground: some View {
        ZStack {
            perfume.family.color.opacity(0.3)
            Image(systemName: "flask")
                .font(.system(size: 48))
                .foregroundStyle(perfume.family.color.opacity(0.4))
        }
        .background(perfume.family.color.opacity(0.1))
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
