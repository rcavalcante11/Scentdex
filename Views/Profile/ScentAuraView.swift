import SwiftUI

struct ScentAuraView: View {

    // MARK: - Properties
    let profile: ScentProfile
    @State private var animate = false
    @State private var viewModel = ScentAuraViewModel()

    // MARK: - Body
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {

                ZStack(alignment: .bottom) {
                    blobsLayer

                    LinearGradient(
                        colors: [.black.opacity(0.3), .clear],
                        startPoint: .top,
                        endPoint: .center
                    )

                    VStack {
                        Spacer()
                        LinearGradient(
                            colors: [.clear, .black],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: 200)
                    }

                    VStack(alignment: .leading, spacing: 0) {
                        Spacer()

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Your Scent Aura")
                                .font(.caption)
                                .fontWeight(.medium)
                                .tracking(3)
                                .foregroundStyle(.white.opacity(0.5))

                            Text(profile.profileTitle)
                                .font(.system(size: 34, weight: .medium))
                                .foregroundStyle(.white)

                            HStack(spacing: 8) {
                                ForEach(topFamilies, id: \.self) { family in
                                    familyTag(family)
                                }
                            }
                        }
                        .padding(.horizontal, 28)

                        Divider()
                            .background(.white.opacity(0.15))
                            .padding(.vertical, 24)
                            .padding(.horizontal, 28)

                        Group {
                            if viewModel.isLoading {
                                HStack(spacing: 8) {
                                    ProgressView()
                                        .scaleEffect(0.7)
                                        .tint(.white.opacity(0.5))
                                    Text("Reading your collection...")
                                        .font(.caption)
                                        .foregroundStyle(.white.opacity(0.4))
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .frame(height: 60)
                            } else {
                                Text(viewModel.description)
                                    .font(.body)
                                    .foregroundStyle(.white.opacity(0.75))
                                    .lineSpacing(6)
                            }
                        }
                        .padding(.horizontal, 28)

                        if !profile.topNotes.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Your signature notes")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.white)

                                FlowLayout(spacing: 8) {
                                    ForEach(profile.topNotes, id: \.self) { note in
                                        Text(note)
                                            .font(.caption)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(.white.opacity(0.15))
                                            .foregroundStyle(.white)
                                            .clipShape(Capsule())
                                    }
                                }
                            }
                            .padding(.horizontal, 28)
                            .padding(.top, 24)
                        }

                        Spacer().frame(height: 40)
                    }
                }
                .frame(minHeight: 700)

                VStack(alignment: .leading, spacing: 24) {
                    familyDistributionSection
                    RecommendationCarouselView(profile: profile)
                }
                .padding(24)
                .background(Color.black)
            }
        }
        .ignoresSafeArea(edges: .top)
        .onAppear {
            animate = true
            Task { await viewModel.generateDescription(for: profile) }
        }
        .background(Color.black)
    }

    // MARK: - Blobs
    private var blobsLayer: some View {
        ZStack {
            ForEach(Array(blobConfigs.enumerated()), id: \.offset) { index, config in
                Circle()
                    .fill(config.color)
                    .frame(width: config.size, height: config.size)
                    .blur(radius: 55)
                    .blendMode(.screen)
                    .offset(
                        x: animate ? config.toX : config.fromX,
                        y: animate ? config.toY : config.fromY
                    )
                    .scaleEffect(animate ? config.toScale : 1.0)
                    .animation(
                        .easeInOut(duration: config.duration)
                        .repeatForever(autoreverses: true)
                        .delay(config.delay),
                        value: animate
                    )
            }
        }
    }

    // MARK: - Family Distribution
    private var familyDistributionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Collection breakdown")
                .font(.subheadline)
                .fontWeight(.semibold)

            ForEach(sortedFamilies, id: \.key) { family, count in
                HStack {
                    Text(family.rawValue)
                        .font(.caption)
                        .frame(width: 80, alignment: .leading)

                    GeometryReader { geo in
                        RoundedRectangle(cornerRadius: 4)
                            .fill(family.color.opacity(0.7))
                            .frame(
                                width: geo.size.width * barWidth(for: count),
                                height: 8
                            )
                    }
                    .frame(height: 8)

                    Text("\(count)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    // MARK: - Helpers
    private func familyTag(_ name: String) -> some View {
        Text(name)
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 12)
            .padding(.vertical, 5)
            .background(.white.opacity(0.15))
            .foregroundStyle(.white)
            .clipShape(Capsule())
    }

    private var topFamilies: [String] {
        sortedFamilies
            .prefix(3)
            .map { $0.key.rawValue }
    }

    private var sortedFamilies: [(key: FragranceFamily, count: Int)] {
        profile.familyDistribution
            .sorted { $0.value > $1.value }
            .map { (key: $0.key, count: $0.value) }
    }

    private func barWidth(for count: Int) -> CGFloat {
        let max = profile.familyDistribution.values.max() ?? 1
        return CGFloat(count) / CGFloat(max)
    }

    private var blobConfigs: [BlobConfig] {
        let c1 = profile.auraColors[0]
        let c2 = profile.auraColors[1]

        return [
            BlobConfig(color: c1,              size: 320, fromX: -80,  fromY: -120, toX: 60,   toY: -30,  toScale: 1.25, duration: 3.2, delay: 0),
            BlobConfig(color: c2,              size: 280, fromX: 90,   fromY: 70,   toX: -50,  toY: 100,  toScale: 0.85, duration: 2.8, delay: 0.3),
            BlobConfig(color: c1.opacity(0.7), size: 240, fromX: 40,   fromY: -90,  toX: -70,  toY: 50,   toScale: 1.15, duration: 4.0, delay: 0.8),
            BlobConfig(color: c2.opacity(0.6), size: 200, fromX: -60,  fromY: 90,   toX: 70,   toY: -50,  toScale: 1.3,  duration: 2.4, delay: 0.5),
            BlobConfig(color: c1.opacity(0.4), size: 160, fromX: 0,    fromY: -50,  toX: -30,  toY: 80,   toScale: 0.9,  duration: 3.6, delay: 1.2)
        ]
    }

    // MARK: - BlobConfig
    private struct BlobConfig {
        let color: Color
        let size: CGFloat
        let fromX: CGFloat
        let fromY: CGFloat
        let toX: CGFloat
        let toY: CGFloat
        let toScale: CGFloat
        let duration: Double
        let delay: Double
    }
}

#Preview {
    ScentAuraView(profile: ScentProfile(
        dominantFamily: .woody,
        secondFamily: .oriental,
        topNotes: ["Bergamot", "Sandalwood", "Cedar"],
        familyDistribution: [
            .woody: 3,
            .oriental: 2,
            .fresh: 1
        ],
        familyScores: [
            .woody: 12.0,
            .oriental: 8.0,
            .fresh: 3.0
        ],
        topAccords: [
            AccordScore(name: "woody", score: 9, family: .woody),
            AccordScore(name: "oud", score: 6, family: .woody),
            AccordScore(name: "amber", score: 5, family: .oriental),
            AccordScore(name: "spicy", score: 3, family: .spicy),
            AccordScore(name: "earthy", score: 2, family: .herbal)
        ]
    ))
}
