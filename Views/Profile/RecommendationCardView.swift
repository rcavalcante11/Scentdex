import SwiftUI

struct RecommendationCardView: View {

    // MARK: - Properties
    let fragrance: FragranceResult

    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            ZStack {
                Color.white.opacity(0.06)

                if let imageUrl = fragrance.bestImageUrl,
                   let url = URL(string: imageUrl) {
                    AsyncImage(url: url) { phase in
                        if case .success(let image) = phase {
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .padding(10)
                        } else {
                            bottlePlaceholder
                        }
                    }
                } else {
                    bottlePlaceholder
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 90)

            VStack(alignment: .leading, spacing: 6) {
                Text(resolvedFamily.rawValue)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(resolvedFamily.color.opacity(0.25), in: Capsule())
                    .foregroundStyle(resolvedFamily.color)

                Text(fragrance.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .lineLimit(2)
                    .foregroundStyle(.white)

                Text(fragrance.brand)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.6))
                    .lineLimit(1)
            }
            .padding(12)
        }
        .frame(width: 160, height: 220)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(.white.opacity(0.18), lineWidth: 0.5)
        )
    }

    // MARK: - Helpers
    private var resolvedFamily: FragranceFamily {
        FragranceFamily(rawValue: fragrance.family.capitalized) ?? .floral
    }

    private var bottlePlaceholder: some View {
        ZStack {
            resolvedFamily.color.opacity(0.08)
            Image(systemName: "flask")
                .font(.system(size: 28))
                .foregroundStyle(resolvedFamily.color.opacity(0.4))
        }
    }
}
