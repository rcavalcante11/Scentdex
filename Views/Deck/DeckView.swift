

import SwiftUI
import  SwiftData

struct DeckView: View {
    
    // MARK: - Properties
    @Environment(\.modelContext) private var modelContext
    @Query private var perfumes: [Perfume]
    @State private var showingAddPerfume = false
    @State var viewModel = DeckViewModel()
    
    // MARK: - Body
    var body: some View  {
        NavigationStack{
            Group {
                if perfumes.isEmpty {
                    emptyStateView
                } else {
                    perfumeListView
                }
            }
            .navigationTitle("My Deck")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddPerfume = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddPerfume) {
                Text("Add Perfume - coming soon")
            }
        }
    }
    
    // MARK: - Subviews
    private var emptyStateView: some View {
        VStack (spacing: 16) {
            
            Image(systemName: "flask")
                .font(.system(size: 64))
                .foregroundStyle(.secondary)
            Text("Your deck is empty")
                .font(.title2)
                .fontWeight(.semibold)
            Text("Add your first perfume to get started")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
    private var perfumeListView: some View {
        List{
            ForEach(perfumes) { perfume in
                Text(perfume.name)
            }
            .onDelete {indexSet in
                for index in indexSet {
                    viewModel.delete(perfumes[index], context: modelContext)
                }
            }
        }
    }
}

#Preview {
    DeckView()
        .modelContainer(for: Perfume.self, inMemory: true)
}
