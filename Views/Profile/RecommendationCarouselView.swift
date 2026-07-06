import SwiftUI
import SwiftData


struct RecommendationCarouselView: View {

    
    // MARK: - Properties
    let profile: ScentProfile
    @Query private var ownedPerfumes: [Perfume]
    @State private var viewModel = RecommendationViewModel()
    @State private var selectedFragrance: FragranceResult? = nil
    @State private var expanded = false
    @State private var isGrid = true

    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            headerView
            contentView
        }
        .task(id: "\(profile.topNotes.joined())-\(profile.familyDistribution.values.reduce(0, +))") {
            await viewModel.loadRecommendations(
                profile: profile,
                ownedPerfumes: ownedPerfumes
            )
        }
    }

    // MARK: - Header
    private var headerView: some View {
        HStack(alignment: .top) {
            Button {
                withAnimation(.easeInOut(duration: 0.35)) {
                    expanded.toggle()
                }
            } label: {
                VStack(alignment: .leading, spacing: 4) {
                    Text("You might also like")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                    Text("Based on your \(profile.profileTitle) profile")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .buttonStyle(.plain)

            Spacer()

            HStack(spacing: 12) {
                if expanded {
                    Button {
                        Task {
                            await viewModel.refresh(
                                profile: profile,
                                ownedPerfumes: ownedPerfumes
                            )
                        }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                            .font(.subheadline)
                            .foregroundStyle(.accent)
                    }
                    .disabled({
                        if case .loading = viewModel.state { return true }
                        return false
                    }())

                    HStack(spacing: 2) {
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) { isGrid = true }
                        } label: {
                            Image(systemName: "square.grid.2x2")
                                .font(.subheadline)
                                .foregroundStyle(isGrid ? .accent : .secondary)
                        }
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) { isGrid = false }
                        } label: {
                            Image(systemName: "list.bullet")
                                .font(.subheadline)
                                .foregroundStyle(!isGrid ? .accent : .secondary)
                        }
                    }
                } else {
                    Image(systemName: "chevron.down")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.35)) {
                                expanded.toggle()
                            }
                        }
                }
            }
        }
        .padding(.horizontal, 24)
    }

    // MARK: - Content
    private var contentView: some View {
        Group {
            switch viewModel.state {
            case .idle:
                EmptyView()
            case .loading:
                loadingView
            case .loaded(let perfumes):
                recommendationsView(perfumes)
            case .empty, .error:
                emptyView
            }
        }
    }

    // MARK: - Recommendations
    private func recommendationsView(_ perfumes: [FragranceResult]) -> some View {
        let all = Array(perfumes.prefix(6))
        let preview = Array(all.prefix(2))

        return VStack(spacing: 0) {
            if expanded {
                if isGrid {
                    gridView(all)
                } else {
                    listView(all)
                }

                Button {
                    withAnimation(.easeInOut(duration: 0.35)) {
                        expanded = false
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.up")
                            .font(.caption2)
                        Text("Show less")
                            .font(.caption)
                    }
                    .foregroundStyle(.secondary)
                    .padding(.top, 12)
                }
                .frame(maxWidth: .infinity)

            } else {
                ZStack(alignment: .bottom) {
                        // Cards sem interacção
                        gridView(preview)
                            .allowsHitTesting(false)
                            .padding(.bottom, 60) // espaço extra para o gradiente cobrir

                        // Gradiente por cima dos cards — cobre da metade para baixo
                        LinearGradient(
                            colors: [.clear, .black],
                            startPoint: .init(x: 0.5, y: 0.3),
                            endPoint: .bottom
                        )
                        .ignoresSafeArea(edges: .bottom)
                        .allowsHitTesting(false)

                        // Pill por cima de tudo
                        Button {
                            withAnimation(.easeInOut(duration: 0.35)) {
                                expanded = true
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "chevron.down")
                                    .font(.caption2)
                                Text("See all \(all.count) recommendations")
                                    .font(.caption)
                            }
                            .foregroundStyle(.secondary)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .background(.ultraThinMaterial)
                            .clipShape(Capsule())
                        }
                        .padding(.bottom, 16)
                    }
                    .frame(height: 280) // altura fixa do preview
                    .clipped()
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.35)) {
                            expanded = true
                        }
                    }
                }
        }
        .sheet(item: $selectedFragrance) { fragrance in
            RecommendationDetailSheet(
                fragrance: fragrance,
                ownedPerfumes: ownedPerfumes
            )
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
    }

    // MARK: - Grid View
    private func gridView(_ perfumes: [FragranceResult]) -> some View {
        LazyVGrid(
            columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)],
            spacing: 12
        ) {
            ForEach(Array(perfumes.enumerated()), id: \.element.id) { index, perfume in
                if index < 4 {
                    Button {
                        selectedFragrance = perfume
                    } label: {
                        RecommendationCardView(fragrance: perfume)
                    }
                    .buttonStyle(.plain)
                } else {
                    RecommendationCardView(fragrance: perfume)
                        .blur(radius: 6)
                        .overlay {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.ultraThinMaterial)
                            VStack(spacing: 8) {
                                Image(systemName: "lock.fill")
                                    .font(.title2)
                                    .foregroundStyle(.secondary)
                                Text("Available on Premium")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.secondary)
                            }
                        }
                }
            }
        }
        .padding(.horizontal, 24)
    }

    // MARK: - List View
    private func listView(_ perfumes: [FragranceResult]) -> some View {
        VStack(spacing: 8) {
            ForEach(Array(perfumes.enumerated()), id: \.element.id) { index, perfume in
                if index < 4 {
                    Button {
                        selectedFragrance = perfume
                    } label: {
                        listCard(perfume)
                    }
                    .buttonStyle(.plain)
                } else {
                    listCard(perfume)
                        .blur(radius: 4)
                        .overlay {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.ultraThinMaterial)
                            HStack(spacing: 6) {
                                Image(systemName: "lock.fill")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text("Available on Premium")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                }
            }
        }
        .padding(.horizontal, 24)
    }

    private func listCard(_ perfume: FragranceResult) -> some View {
        HStack(spacing: 12) {
            Group {
                if let imageUrl = perfume.bestImageUrl,
                   let url = URL(string: imageUrl) {
                    AsyncImage(url: url) { phase in
                        if case .success(let image) = phase {
                            image.resizable().aspectRatio(contentMode: .fit)
                        } else {
                            Image(systemName: "flask")
                                .foregroundStyle(.secondary)
                        }
                    }
                } else {
                    Image(systemName: "flask")
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 56, height: 72)
            .background(Color.secondary.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 4) {
                Text(perfume.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .lineLimit(2)
                    .foregroundStyle(.primary)
                Text(perfume.brand)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                if let gender = perfume.gender {
                    Text(gender)
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(12)
        .background(Color.secondary.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Loading / Empty
    private var loadingView: some View {
        LazyVGrid(
            columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)],
            spacing: 12
        ) {
            ForEach(0..<2, id: \.self) { _ in
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.secondary.opacity(0.15))
                    .frame(height: 200)
            }
        }
        .padding(.horizontal, 24)
    }

    private var emptyView: some View {
        Text("No recommendations available yet")
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .padding(.horizontal, 24)
    }
}
