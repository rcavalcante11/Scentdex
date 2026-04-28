

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
                AddPerfumeView()
            }
            
            .alert("Remove Perfume", isPresented: $viewModel.showingDeleteAlert){
                Button("Remove", role: .destructive) {
                    if let perfume = viewModel.perfumeToDelete {
                        viewModel.delete(perfume,context: modelContext)
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Are you sure you want  to remove \(viewModel.perfumeToDelete?.name ?? "this perfume") from your deck?")
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
                NavigationLink(destination: PerfumeDetailView(perfume: perfume)) {
                    PerfumeCardView(perfume: perfume)
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                }
            }
            .onDelete {indexSet in
                for index in indexSet {
                    let perfume = perfumes[index]
                    viewModel.confirmDelete(perfume, context: modelContext)
                }
            }
        }
        .listStyle(.plain)
    }
}

#Preview {
 
    let container = try! ModelContainer(
            for: Perfume.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        
        for perfume in Perfume.sampleData {
            container.mainContext.insert(perfume)
        }
        
        return DeckView()
            .modelContainer(container)
}
