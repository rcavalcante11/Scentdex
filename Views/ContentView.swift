import SwiftUI
import SwiftData

struct ContentView: View {
    
    // MARK: - Properties
    @Query private var perfumes: [Perfume]
    
    //MARK: - Body
    var body: some View {
        TabView {
            Tab ("My Deck", systemImage: "rectangle.stack.fill") {
                DeckView()
            }
            
            Tab ("Scent Aura", systemImage: "sparkles") {
                scentAuraTab
            }
        }
    }
    
    // MARK: - Subviews
    @ViewBuilder
    private var scentAuraTab: some View {
        if let profile = ScentProfile.calculate(from: perfumes) {
            NavigationStack {
                ScentAuraView(profile: profile)
                    .navigationTitle("Scent Aura")
                    .navigationBarTitleDisplayMode(.inline)
            }
        } else {
            emptyAuraView
        }
    }
    
    private var  emptyAuraView: some View {
        VStack(spacing: 16) {
            Image(systemName: "sparkles")
                .foregroundStyle(.secondary)
            Text("Your Aura is waiting")
                .font(.title2)
                .fontWeight(.semibold)
                Text("Add at least one perfume to your deck to see your Scent Aura")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center )
                .padding(.horizontal, 32)
                
            }
        }
    }

#Preview {
    ContentView()
        .modelContainer(for: Perfume.self, inMemory: true)
}
