import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var selectedTab = 1
    
    // MARK: - Properties
    @Query private var perfumes: [Perfume]
    
    //MARK: - Body
    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("My Deck", systemImage: "rectangle.stack.fill", value: 0) {
                DeckView()
            }

            Tab("Feed", systemImage: "newspaper.fill", value: 1) {
                FeedView()
            }

            Tab("Scent Aura", systemImage: "sparkles", value: 2) {
                scentAuraTab
            }
        }
        .preferredColorScheme(.dark)
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
