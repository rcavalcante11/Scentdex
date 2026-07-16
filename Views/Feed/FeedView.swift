import SwiftUI
import SwiftData

struct FeedView: View {

    // MARK: - Properties
    @State private var viewModel: FeedViewModel = FeedViewModel()
    @Query private var perfumes: [Perfume]
    @State private var selectedFragrance: FragranceResult?
    @State private var selectedTab: FeedTab = .discover

    private var ownedPerfumes: [Perfume] {
        perfumes.filter { !$0.isWishlist }
    }

    // MARK: - Body
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    tabSwitcher

                    switch selectedTab {
                    case .discover:
                        fragranceSection(
                            title: "Trending Now",
                            subtitle: "Most loved this season",
                            fragrances: viewModel.trending,
                            isLoading: viewModel.isLoadingFragrances
                        )

                        fragranceSection(
                            title: "New Releases",
                            subtitle: "Fresh from the houses",
                            fragrances: viewModel.newReleases,
                            isLoading: viewModel.isLoadingFragrances
                        )

                    case .articles:
                        articlesSection
                    }
                }
                .padding(.bottom, 32)
            }
            .navigationTitle("Feed")
            .navigationBarTitleDisplayMode(.large)
        }
        .task {
            await viewModel.loadContent()
        }
        .sheet(item: $selectedFragrance) { fragrance in
            RecommendationDetailSheet(fragrance: fragrance, ownedPerfumes: ownedPerfumes)
        }
    }

    // MARK: - Tab Switcher
    private var tabSwitcher: some View {
        GeometryReader { geo in
            let tabWidth = geo.size.width / 2
            let blobSize: CGFloat = 100
            let blobCenterY = geo.size.height // centro exactamente na linha de corte, para um meio-círculo limpo
            let blobX = (selectedTab == .discover ? tabWidth / 2 : tabWidth + tabWidth / 2) - blobSize / 2

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
                    feedTabButton(.discover, title: "Discover")
                    feedTabButton(.articles, title: "Articles")
                }
            }
        }
        .frame(height: 48)
        .clipped()
        .padding(.horizontal)
        .padding(.top, 8)
        .padding(.bottom, 4)
    }

    private func feedTabButton(_ tab: FeedTab, title: String) -> some View {
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

    // MARK: - Sections
    private var articlesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader(
                title: "From the World of Fragrance",
                subtitle: "Tips, guides and ingredients"
            )

            VStack(spacing: 12) {
                ForEach(viewModel.articles) { article in
                    FeedArticleCard(article: article)
                }
            }
            .padding(.horizontal, 16)
        }
    }

    private func fragranceSection(
        title: String,
        subtitle: String,
        fragrances: [FragranceResult],
        isLoading: Bool
    ) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader(title: title, subtitle: subtitle)

            if isLoading {
                loadingRow
            } else if fragrances.isEmpty {
                emptyFragranceRow
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(fragrances) { fragrance in
                            FeedFragranceCard(fragrance: fragrance) {
                                selectedFragrance = fragrance
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }
        }
    }

    // MARK: - Helpers
    private func sectionHeader(title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.title3)
                .fontWeight(.semibold)
                .padding(.horizontal, 16)

            Text(subtitle)
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 16)
        }
    }

    private var loadingRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(0..<4, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color(.systemGray6).opacity(0.3))
                        .frame(width: 140, height: 184)
                }
            }
            .padding(.horizontal, 16)
        }
    }

    private var emptyFragranceRow: some View {
        Text("Available when connected to Fragella")
            .font(.caption)
            .foregroundStyle(.secondary)
            .padding(.horizontal, 16)
    }
}

// MARK: - FeedTab
enum FeedTab: String, CaseIterable, Identifiable {
    case discover
    case articles

    var id: String { rawValue }
}
