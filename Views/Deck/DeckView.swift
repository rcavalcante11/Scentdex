import SwiftUI
import SwiftData

struct DeckView: View {

    // MARK: - Properties
    @Environment(\.modelContext) private var modelContext
    @Query private var perfumes: [Perfume]
    @State private var showingAddPerfume = false
    @State var viewModel = DeckViewModel()
    @State private var searchText = ""

    private var filteredPerfumes: [Perfume] {
        if searchText.isEmpty { return perfumes }
        return perfumes.filter { perfume in
            perfume.name.localizedCaseInsensitiveContains(searchText) ||
            perfume.brand.localizedCaseInsensitiveContains(searchText) ||
            perfume.family.rawValue.localizedCaseInsensitiveContains(searchText)
        }
    }

    private var isSearching: Bool { !searchText.isEmpty }

    // MARK: - Body
    var body: some View {
        NavigationStack {
            Group {
                if !isSearching && perfumes.isEmpty {
                    emptyStateView
                } else {
                    searchResultsView
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
            .searchable(text: $searchText, prompt: "Search your deck or database")
            .onChange(of: searchText) { _, newValue in
                Task { await viewModel.searchAPI(query: newValue) }
            }
            .sheet(isPresented: $showingAddPerfume) {
                AddPerfumeView()
            }
            .alert("Remove Perfume", isPresented: $viewModel.showingDeleteAlert) {
                Button("Remove", role: .destructive) {
                    if let perfume = viewModel.perfumeToDelete {
                        viewModel.delete(perfume, context: modelContext)
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Are you sure you want to remove \(viewModel.perfumeToDelete?.name ?? "this perfume") from your deck?")
            }
        }
    }

    // MARK: - Subviews
    private var emptyStateView: some View {
        VStack(spacing: 16) {
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

    private var searchResultsView: some View {
        List {
            
            if !filteredPerfumes.isEmpty {
                Section("In Your Deck") {
                    ForEach(filteredPerfumes) { perfume in
                        NavigationLink(destination: PerfumeDetailView(perfume: perfume)) {
                            PerfumeCardView(perfume: perfume)
                                .listRowInsets(EdgeInsets())
                                .listRowBackground(Color.clear)
                        }
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            viewModel.confirmDelete(filteredPerfumes[index])
                        }
                    }
                }
            }

            // API Search
            if isSearching {
                Section("From Database") {
                    if viewModel.isSearchingAPI {
                        HStack {
                            ProgressView()
                                .scaleEffect(0.8)
                            Text("Searching database...")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    } else if viewModel.apiSearchResults.isEmpty {
                        Text("No results found")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(viewModel.apiSearchResults) { result in
                            apiResultRow(result)
                        }
                    }
                }
            }
        }
        .listStyle(.plain)
    }

    private func apiResultRow(_ result: FragranceResult) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(result.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text(result.brand)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                Text(result.family.capitalized)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(
                        (FragranceFamily(rawValue: result.family.capitalized)?.color ?? .gray)
                            .opacity(0.2)
                    )
                    .foregroundStyle(
                        FragranceFamily(rawValue: result.family.capitalized)?.color ?? .gray
                    )
                    .clipShape(Capsule())

                Button("+ Add") {
                    addFromAPI(result)
                }
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.accent)
            }
        }
        .padding(.vertical, 4)
    }

    // MARK: - Helpers
    private func addFromAPI(_ result: FragranceResult) {
        let family = FragranceFamily(rawValue: result.family.capitalized) ?? .floral
        let gender = PerfumeGender(rawValue: result.gender ?? "") ?? .forWomenAndMen
        let perfume = Perfume(
            name: result.name,
            brand: result.brand,
            family: family,
            gender: gender,
            topNotes: result.topNotes ?? [],
            middleNotes: result.middleNotes ?? [],
            baseNotes: result.baseNotes ?? [],
            imageUrl: result.imageUrl
        )
        modelContext.insert(perfume)
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
