import SwiftUI

struct RecommendationCardView: View {

    // MARK: - Properties
    let fragrance: FragranceResult

    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            // Family pill
            Text(fragrance.family.capitalized)
                .font(.caption)
                .fontWeight(.medium)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(resolvedFamily.color.opacity(0.2))
                .foregroundStyle(resolvedFamily.color)
                .clipShape(Capsule())

            Spacer()

            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(fragrance.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .lineLimit(2)
                    .foregroundStyle(.primary)

                Text(fragrance.brand)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if let gender = fragrance.gender {
                    Text(gender)
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }
        }
        .padding(16)
        .frame(width: 160, height: 200)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
    }

    // MARK: - Helpers
    private var resolvedFamily: FragranceFamily {
        FragranceFamily(rawValue: fragrance.family.capitalized) ?? .floral
    }
}
