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
                            .foregroundStyle(.accent)
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
        HStack(spacing: 12) {
            Group {
                if let imageUrl = result.imageUrl,
                   let url = URL(string: imageUrl) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        default:
                            placeholderBottle(family: result.family)
                        }
                    }
                } else {
                    placeholderBottle(family: result.family)
                }
            }
            .frame(width: 40, height: 50)
            .clipShape(RoundedRectangle(cornerRadius: 6))

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
                Text(mapFamily(result.family).rawValue)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(mapFamily(result.family).color.opacity(0.2))
                    .foregroundStyle(mapFamily(result.family).color)
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

    private func placeholderBottle(family: String) -> some View {
        ZStack {
            mapFamily(family).color.opacity(0.15)
            Image(systemName: "flask")
                .font(.system(size: 16))
                .foregroundStyle(mapFamily(family).color.opacity(0.6))
        }
    }

    // MARK: - Helpers
    private func addFromAPI(_ result: FragranceResult) {
        let perfume = Perfume(
            name: result.name,
            brand: result.brand,
            family: mapFamily(result.family),
            gender: mapGender(result.gender ?? ""),
            topNotes: result.topNotes ?? result.generalNotes ?? [],
            middleNotes: result.middleNotes ?? [],
            baseNotes: result.baseNotes ?? [],
            imageUrl: result.imageUrl
        )
        modelContext.insert(perfume)
    }

    // MARK: - Mapping
    private func mapFamily(_ raw: String) -> FragranceFamily {
        let lower = raw.lowercased().trimmingCharacters(in: .whitespaces)
        switch lower {

        // Woody
        case "woody", "wood", "oud", "sandalwood",
             "cedar", "vetiver", "patchouli":
            return .woody

        // Floral
        case "floral", "flower", "white floral",
             "yellow floral", "rose", "powdery",
             "musky", "aldehydic", "lactonic", "iris",
             "violet", "tuberose":
            return .floral

        // Oriental
        case "oriental", "amber", "balsamic",
             "warm spicy", "tobacco", "leather",
             "smoky", "animalic", "incense", "resinous":
            return .oriental

        // Fresh
        case "fresh", "fruity", "tropical",
             "light spicy", "soft spicy":
            return .fresh

        // Citrus
        case "citrus", "citric", "lemon",
             "bergamot", "orange", "grapefruit":
            return .citrus

        // Aquatic
        case "aquatic", "marine", "water",
             "oceanic", "sea":
            return .aquatic

        // Gourmand
        case "gourmand", "sweet", "vanilla",
             "chocolate", "caramel", "coffee",
             "food", "honey":
            return .gourmand

        // Spicy
        case "spicy", "spice", "fresh spicy",
             "cinnamon", "pepper", "cardamom":
            return .spicy

        // Herbal
        case "herbal", "green", "fougere",
             "aromatic", "mossy", "earthy",
             "conifer", "lavender", "mint":
            return .herbal

        default:
            return .floral
        }
    }

    private func mapGender(_ raw: String) -> PerfumeGender {
        let lower = raw.lowercased().trimmingCharacters(in: .whitespaces)
        switch lower {
        case "men", "masculine", "for men":          return .forMen
        case "women", "feminine", "for women":       return .forWomen
        case "unisex", "for women and men", "both":  return .forWomenAndMen
        default:                                      return .forWomenAndMen
        }
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
