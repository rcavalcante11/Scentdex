import SwiftUI
import SwiftData

struct DeckView: View {

    // MARK: - Properties
    let blobTransitionState: BlobTransitionState

    @Environment(\.modelContext) private var modelContext
    @Query private var perfumes: [Perfume]
    @State private var showingAddPerfume = false
    @State var viewModel = DeckViewModel()
    @State private var searchText = ""
    @State private var selectedTab: DeckTab = .collection
    @State private var isGrid = false

    private var profile: ScentProfile? {
        ScentProfile.calculate(from: perfumes)
    }

    private var basePerfumes: [Perfume] {
        perfumes.filter { $0.isWishlist == (selectedTab == .wishlist) }
    }

    private var filteredPerfumes: [Perfume] {
        if searchText.isEmpty { return basePerfumes }
        return basePerfumes.filter { perfume in
            perfume.name.localizedCaseInsensitiveContains(searchText) ||
            perfume.brand.localizedCaseInsensitiveContains(searchText) ||
            perfume.family.rawValue.localizedCaseInsensitiveContains(searchText)
        }
    }

    private var isSearching: Bool { !searchText.isEmpty }

    // MARK: - Body
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                AmbientBlobLayer(profile: profile, transitionState: blobTransitionState)
                    .ignoresSafeArea()

                globalDarkening

                List {
                    tabSwitcher
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)

                    if !isSearching && basePerfumes.isEmpty {
                        emptyStateView
                            .listRowInsets(EdgeInsets())
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                    } else {
                        if !filteredPerfumes.isEmpty {
                            Section(selectedTab == .wishlist ? "In Your Wishlist" : "In Your Deck") {
                                if isGrid {
                                    gridContent
                                        .listRowInsets(EdgeInsets())
                                        .listRowBackground(Color.clear)
                                        .listRowSeparator(.hidden)
                                } else {
                                    ForEach(filteredPerfumes) { perfume in
                                        NavigationLink(value: perfume) {
                                            PerfumeCardView(perfume: perfume)
                                        }
                                        .listRowInsets(EdgeInsets())
                                        .listRowBackground(Color.clear)
                                    }
                                    .onDelete { indexSet in
                                        for index in indexSet {
                                            viewModel.confirmDelete(filteredPerfumes[index])
                                        }
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
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
            .navigationDestination(for: Perfume.self) { perfume in
                PerfumeDetailView(perfume: perfume)
            }
            .navigationTitle("My Deck")
            .navigationDestination(for: Perfume.self) { perfume in
                PerfumeDetailView(perfume: perfume)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 16) {
                        HStack(spacing: 10) {
                            Button {
                                withAnimation(.easeInOut(duration: 0.2)) { isGrid = true }
                            } label: {
                                Image(systemName: "square.grid.2x2")
                                    .foregroundStyle(isGrid ? .accent : .secondary)
                            }
                            Button {
                                withAnimation(.easeInOut(duration: 0.2)) { isGrid = false }
                            } label: {
                                Image(systemName: "list.bullet")
                                    .foregroundStyle(!isGrid ? .accent : .secondary)
                            }
                        }

                        Button {
                            showingAddPerfume = true
                        } label: {
                            Image(systemName: "plus")
                                .foregroundStyle(.accent)
                        }
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
                Text("Are you sure you want to remove \(viewModel.perfumeToDelete?.name ?? "this perfume") from your \(selectedTab == .wishlist ? "wishlist" : "deck")?")
            }
        }
    }

    // MARK: - Global darkening
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

    // MARK: - Subviews
    private var gridContent: some View {
        LazyVGrid(
            columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)],
            spacing: 12
        ) {
            ForEach(filteredPerfumes) { perfume in
                NavigationLink(value: perfume) {
                    PerfumeCardView(perfume: perfume)
                }
                .buttonStyle(.plain)
                .contextMenu {
                    Button(role: .destructive) {
                        viewModel.confirmDelete(perfume)
                    } label: {
                        Label("Remove", systemImage: "trash")
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 4)
    }

    private var tabSwitcher: some View {
        GeometryReader { geo in
            let tabWidth = geo.size.width / 2
            let blobSize: CGFloat = 100
            let blobCenterY = geo.size.height
            let blobX = (selectedTab == .collection ? tabWidth / 2 : tabWidth + tabWidth / 2) - blobSize / 2

            ZStack(alignment: .topLeading) {
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(stops: [
                                .init(color: Color.accentColor.opacity(0.65), location: 0.0),
                                .init(color: Color.accentColor.opacity(0.35), location: 0.55),
                                .init(color: Color.accentColor.opacity(0.0), location: 1.0)
                            ]),
                            center: .center,
                            startRadius: 0,
                            endRadius: blobSize / 2
                        )
                    )
                    .frame(width: blobSize, height: blobSize)
                    .offset(x: blobX, y: blobCenterY - blobSize / 2)

                HStack(spacing: 0) {
                    tabButton(.collection, title: "Collection")
                    tabButton(.wishlist, title: "Wishlist")
                }
            }
        }
        .frame(height: 48)
        .clipped()
        .padding(.horizontal)
        .padding(.top, 8)
        .padding(.bottom, 4)
    }

    private func tabButton(_ tab: DeckTab, title: String) -> some View {
        Button {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.75)) {
                selectedTab = tab
            }
        } label: {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(selectedTab == tab ? .primary : .secondary)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
        }
        .buttonStyle(.plain)
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: selectedTab == .wishlist ? "heart" : "flask")
                .font(.system(size: 64))
                .foregroundStyle(.secondary)
            Text(selectedTab == .wishlist ? "Your wishlist is empty" : "Your deck is empty")
                .font(.title2)
                .fontWeight(.semibold)
            Text(selectedTab == .wishlist
                 ? "Save perfumes you'd like to try someday"
                 : "Add your first perfume to get started")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .padding(.top, 60)
        .frame(maxWidth: .infinity)
    }

    private func apiResultRow(_ result: FragranceResult) -> some View {

        return HStack(spacing: 12) {
            Group {
                if let imageUrl = result.bestImageUrl,
                   let url = URL(string: imageUrl) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image.resizable().aspectRatio(contentMode: .fit)
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
            VStack(alignment: .trailing, spacing: 6) {
                Text(mapFamily(result.family).rawValue)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(.ultraThinMaterial, in: Capsule())
                    .foregroundStyle(mapFamily(result.family).color)
                    .overlay(
                        Capsule().stroke(mapFamily(result.family).color.opacity(0.4), lineWidth: 0.5)
                    )

                HStack(spacing: 16) {
                    Button {
                        addFromAPI(result, isWishlist: false)
                    } label: {
                        VStack(spacing: 2) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 20))
                                .foregroundStyle(.accent)
                            Text("Deck")
                                .font(.system(size: 9, weight: .semibold))
                                .foregroundStyle(.accent)
                        }
                    }
                    .buttonStyle(IconPressStyle(tint: .accentColor))

                    Button {
                        addFromAPI(result, isWishlist: true)
                    } label: {
                        VStack(spacing: 2) {
                            Image(systemName: "heart.circle.fill")
                                .font(.system(size: 20))
                                .foregroundStyle(.pink)
                            Text("Wishlist")
                                .font(.system(size: 9, weight: .semibold))
                                .foregroundStyle(.pink)
                        }
                    }
                    .buttonStyle(IconPressStyle(tint: .pink))
                }
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
    private func addFromAPI(_ result: FragranceResult, isWishlist: Bool) {
        let perfume = Perfume(
            name: result.name,
            brand: result.brand,
            family: mapFamily(result.family),
            gender: resolvedGender(for: result),
            topNotes: result.topNotes ?? result.generalNotes ?? [],
            middleNotes: result.middleNotes ?? [],
            baseNotes: result.baseNotes ?? [],
            imageUrl: result.bestImageUrl,
            accordsData: result.accordsJSON,
            isWishlist: isWishlist
        )
        modelContext.insert(perfume)
        searchText = ""
        viewModel.apiSearchResults = []
    }

    // MARK: - Mapping
    private func mapFamily(_ raw: String) -> FragranceFamily {
        let lower = raw.lowercased().trimmingCharacters(in: .whitespaces)
        switch lower {
        case "woody", "wood", "oud", "sandalwood",
             "cedar", "vetiver", "patchouli":
            return .woody
        case "floral", "flower", "white floral",
             "yellow floral", "rose", "powdery",
             "musky", "aldehydic", "lactonic", "iris",
             "violet", "tuberose":
            return .floral
        case "oriental", "amber", "balsamic",
             "warm spicy", "tobacco", "leather",
             "smoky", "animalic", "incense", "resinous":
            return .oriental
        case "fresh", "fruity", "tropical",
                 "light spicy", "soft spicy":
                return .fresh
        case "citrus", "citric", "lemon",
             "bergamot", "orange", "grapefruit":
            return .citrus
        case "aquatic", "marine", "water",
             "oceanic", "sea":
            return .aquatic
        case "gourmand", "sweet", "vanilla",
             "chocolate", "caramel", "coffee",
             "food", "honey":
            return .gourmand
        case "spicy", "spice", "fresh spicy",
             "cinnamon", "pepper", "cardamom":
            return .spicy
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

    private func genderHeuristic(from name: String) -> PerfumeGender? {
        let tokens = name.lowercased()
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { !$0.isEmpty }

        let femaleTokens: Set<String> = ["woman", "women", "femme", "her", "lady", "elle"]
        let maleTokens: Set<String> = ["man", "men", "homme", "him", "gentleman"]

        let hasFemale = tokens.contains { femaleTokens.contains($0) }
        let hasMale = tokens.contains { maleTokens.contains($0) }

        if hasFemale && !hasMale { return .forWomen }
        if hasMale && !hasFemale { return .forMen }
        return nil
    }

    private func resolvedGender(for result: FragranceResult) -> PerfumeGender {
        genderHeuristic(from: result.name) ?? mapGender(result.gender ?? "")
    }
}

// MARK: - IconPressStyle
struct IconPressStyle: ButtonStyle {
    let tint: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.85 : 1.0)
            .shadow(
                color: tint.opacity(configuration.isPressed ? 0.5 : 0.0),
                radius: configuration.isPressed ? 6 : 0,
                y: configuration.isPressed ? 2 : 0
            )
            .animation(.spring(response: 0.25, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - DeckTab
enum DeckTab: String, CaseIterable, Identifiable {
    case collection
    case wishlist

    var id: String { rawValue }

    var title: String {
        switch self {
        case .collection: return "Collection"
        case .wishlist: return "Wishlist"
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
    return DeckView(blobTransitionState: BlobTransitionState())
        .modelContainer(container)
}
