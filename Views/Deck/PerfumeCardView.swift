import SwiftUI
import SwiftData

struct PerfumeCardView: View{
    
    // MARK properties
    let perfume: Perfume
    
    //MARK Body
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack{
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
                    .background(familyColor.opacity(0.2))
                    .foregroundStyle(familyColor)
                    .clipShape(Capsule())
        }
    }
        .padding()
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 2)
            }
    
    // MARK: - Helpers
       private var familyColor: Color {
           switch perfume.family {
           case .floral:    return .pink
           case .woody:     return .brown
           case .oriental:  return .orange
           case .fresh:     return .mint
           case .citrus:    return .yellow
           case .aquatic:   return .blue
           case .gourmand:  return .purple
           case .spicy:     return .red
           case .herbal:    return .green
           }
       }
   }

#Preview {
    PerfumeCardView(perfume: Perfume(
        name: "Bleu de Chanel",
        brand: "Chanel",
        family: .woody,
        topNotes: ["Bergamot", "Lemon"],
        middleNotes: ["Ginger", "Nutmeg"],
        baseNotes: ["Sandalwood", "Cedar"]
    ))
    .padding()
    .modelContainer(for: Perfume.self, inMemory: true)
}

