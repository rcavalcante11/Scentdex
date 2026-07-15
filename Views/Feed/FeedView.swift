import SwiftUI
import SwiftData

struct FeedView: View {

    // MARK: - Properties
    @State private var viewModel: FeedViewModel = FeedViewModel()
    @Query private var perfumes: [Perfume]
    @State private var selectedFragrance: FragranceResult?

    private var ownedPerfumes: [Perfume] {
        perfumes.filter { !$0.isWishlist }
    }

    // MARK: - Body
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {

                    fragranceSection(
                        title: "Trending Now",
                        subtitle: "Most loved this season",
                        fragrances: viewModel.trending,
                        isLoading: viewModel.isLoadingFragrances
                    )

                    articlesSection

                    fragranceSection(
                        title: "New Releases",
                        subtitle: "Fresh from the houses",
                        fragrances: viewModel.newReleases,
                        isLoading: viewModel.isLoadingFragrances
                    )
                }
                .padding(.top, 8)
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
