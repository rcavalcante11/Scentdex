import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var selectedTab = 1
    @State private var blobTransitionState = BlobTransitionState()

    // MARK: - Properties
    @Query private var perfumes: [Perfume]

    // MARK: - Body
    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("My Deck", systemImage: "rectangle.stack.fill", value: 0) {
                DeckView(blobTransitionState: blobTransitionState)
            }

            Tab("Feed", systemImage: "newspaper.fill", value: 1) {
                FeedView(blobTransitionState: blobTransitionState)
            }

            Tab("Scent Aura", systemImage: "sparkles", value: 2) {
                scentAuraTab
            }
        }
        .toolbarBackground(.hidden, for: .tabBar)
        .onChange(of: selectedTab) { oldValue, newValue in
            blobTransitionState.recordTransition(from: oldValue, to: newValue)
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Derived
    private var currentProfile: ScentProfile? {
        ScentProfile.calculate(from: perfumes)
    }

    // MARK: - Subviews
    @ViewBuilder
    private var scentAuraTab: some View {
        if let profile = currentProfile {
            NavigationStack {
                ZStack {
                    Color.black.ignoresSafeArea()

                    AmbientBlobLayer(profile: profile, transitionState: blobTransitionState)
                        .ignoresSafeArea()

                    globalDarkening

                    ScentAuraView(profile: profile)
                }
                .navigationTitle("Scent Aura")
                .navigationBarTitleDisplayMode(.inline)
                .toolbarBackground(.hidden, for: .navigationBar)
                .toolbarColorScheme(.dark, for: .navigationBar)
            }
        } else {
            emptyAuraView
        }
    }

    private var globalDarkening: some View {
        LinearGradient(
            stops: [
                .init(color: .black.opacity(0.1), location: 0.0),
                .init(color: .black.opacity(0.45), location: 0.4),
                .init(color: .black.opacity(0.6), location: 0.65),
                .init(color: .black.opacity(0.6), location: 1.0)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }

    private var emptyAuraView: some View {
        VStack(spacing: 16) {
            Image(systemName: "sparkles")
                .foregroundStyle(.secondary)
            Text("Your Aura is waiting")
                .font(.title2)
                .fontWeight(.semibold)
            Text("Add at least one perfume to your deck to see your Scent Aura")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Perfume.self, inMemory: true)
}
