import SwiftUI

struct ScentAuraView: View {

    // MARK: - Properties
    let profile: ScentProfile
    @State private var animate = false
    @State private var viewModel = ScentAuraViewModel()
    @State private var descriptionExpanded = false
    @State private var fingerprintExpanded = false
    @State private var radarAnimated = false

    private let descriptionLineLimit = 4

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

                        // MARK: Label + Accord pills
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Your Scent Aura")
                                .font(.caption)
                                .fontWeight(.medium)
                                .tracking(3)
                                .foregroundStyle(.white.opacity(0.5))

                            Text(viewModel.generatedLabel.isEmpty ? profile.profileTitle : viewModel.generatedLabel)
                                .font(.system(size: 34, weight: .medium))
                                .foregroundStyle(.white)

                            HStack(spacing: 8) {
                                ForEach(topAccordTags, id: \.self) { name in
                                    accordTag(name)
                                }
                            }
                        }
                        .padding(.horizontal, 28)

                        Divider()
                            .background(.white.opacity(0.15))
                            .padding(.vertical, 24)
                            .padding(.horizontal, 28)

                        // MARK: Description
                        descriptionSection
                            .padding(.horizontal, 28)

                        // MARK: Aura Fingerprint dropdown
                        auraFingerprintSection
                            .padding(.horizontal, 28)
                            .padding(.top, 16)

                        Spacer().frame(height: 40)
                    }
                }
                .frame(minHeight: 700)

                // MARK: Collection breakdown + Recommendations
                VStack(alignment: .leading, spacing: 24) {
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
        .onChange(of: profile.topAccords.map { $0.name }) { _, _ in
            viewModel.reset()
            Task { await viewModel.generateDescription(for: profile) }
        }
        .background(Color.black)
    }

    // MARK: - Description Section
    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
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
                ZStack(alignment: .bottom) {
                    Text(parseMarkdown(viewModel.description))
                        .font(.body)
                        .foregroundStyle(.white.opacity(0.75))
                        .lineSpacing(6)
                        .lineLimit(descriptionExpanded ? nil : descriptionLineLimit)
                        .animation(.easeInOut(duration: 0.3), value: descriptionExpanded)
                        .mask(
                            Group {
                                if !descriptionExpanded {
                                    LinearGradient(
                                        colors: [.white, .white, .clear],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                } else {
                                    Rectangle().fill(.white)
                                }
                            }
                        )
                }
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        descriptionExpanded.toggle()
                    }
                }

                if !descriptionExpanded {
                    Text("Read more")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.4))
                        .padding(.top, 2)
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                descriptionExpanded = true
                            }
                        }
                }
            }
        }
    }

    // MARK: - Aura Fingerprint Section
    private var auraFingerprintSection: some View {
        VStack(spacing: 0) {
            // Trigger button
            Button {
                withAnimation(.easeInOut(duration: 0.35)) {
                    fingerprintExpanded.toggle()
                }
                if fingerprintExpanded && !radarAnimated {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        withAnimation(.easeOut(duration: 0.8)) {
                            radarAnimated = true
                        }
                    }
                }
            } label: {
                HStack(spacing: 10) {
                    // Mini blobs
                    HStack(spacing: -4) {
                        ForEach(0..<3, id: \.self) { i in
                            Circle()
                                .fill(blobColors[i])
                                .frame(width: 16, height: 16)
                                .blur(radius: 3)
                        }
                    }

                    Text("Aura Fingerprint")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.white.opacity(0.7))

                    Spacer()

                    Image(systemName: "chevron.down")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.4))
                        .rotationEffect(.degrees(fingerprintExpanded ? 180 : 0))
                        .animation(.easeInOut(duration: 0.3), value: fingerprintExpanded)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(.white.opacity(0.07))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(.white.opacity(0.1), lineWidth: 0.5)
                )
            }

            // Expanded content
            if fingerprintExpanded {
                VStack(alignment: .leading, spacing: 16) {

                    // Signature Notes
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Signature Notes")
                            .font(.caption)
                            .fontWeight(.medium)
                            .tracking(1.5)
                            .foregroundStyle(.white.opacity(0.4))

                        FlowLayout(spacing: 8) {
                            ForEach(profile.topNotes, id: \.self) { note in
                                Text(note)
                                    .font(.caption)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(.white.opacity(0.1))
                                    .foregroundStyle(.white.opacity(0.8))
                                    .clipShape(Capsule())
                            }
                        }
                    }

                    Divider()
                        .background(.white.opacity(0.1))

                    // Accord Breakdown
                    Text("Accord Breakdown")
                        .font(.caption)
                        .fontWeight(.medium)
                        .tracking(1.5)
                        .foregroundStyle(.white.opacity(0.4))

                    HStack(alignment: .center, spacing: 16) {
                        // Radar
                        RadarView(
                            accords: profile.topAccords,
                            animated: radarAnimated
                        )
                        .frame(width: 100, height: 100)

                        // Bars
                        VStack(alignment: .leading, spacing: 6) {
                            ForEach(profile.topAccords.prefix(5), id: \.name) { accord in
                                HStack(spacing: 6) {
                                    Circle()
                                        .fill(accord.family.color)
                                        .frame(width: 6, height: 6)
                                    Text(accord.name.capitalized)
                                        .font(.caption2)
                                        .foregroundStyle(.white.opacity(0.6))
                                        .frame(width: 52, alignment: .leading)
                                    GeometryReader { geo in
                                        RoundedRectangle(cornerRadius: 2)
                                            .fill(accord.family.color.opacity(0.6))
                                            .frame(
                                                width: radarAnimated
                                                    ? geo.size.width * barRatio(accord.score)
                                                    : 0,
                                                height: 3
                                            )
                                            .animation(
                                                .easeOut(duration: 0.6)
                                                .delay(Double(profile.topAccords.firstIndex(where: { $0.name == accord.name }) ?? 0) * 0.08),
                                                value: radarAnimated
                                            )
                                    }
                                    .frame(height: 3)
                                    Text("\(Int(accord.score))")
                                        .font(.caption2)
                                        .foregroundStyle(.white.opacity(0.3))
                                        .frame(width: 20, alignment: .trailing)
                                }
                            }
                        }
                    }
                }
                .padding(14)
                .background(.white.opacity(0.04))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .move(edge: .top)),
                    removal: .opacity.combined(with: .move(edge: .top))
                ))
            }
        }
    }

    // MARK: - Helpers
    private func accordTag(_ name: String) -> some View {
        Text(name)
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 12)
            .padding(.vertical, 5)
            .background(.white.opacity(0.15))
            .foregroundStyle(.white)
            .clipShape(Capsule())
    }

    private var topAccordTags: [String] {
        profile.topAccords.prefix(3).map { $0.name }
    }


    private func barRatio(_ score: Double) -> CGFloat {
        let max = profile.topAccords.first?.score ?? 1
        return CGFloat(score / max)
    }

    private var blobColors: [Color] {
        let sorted = profile.topAccords.prefix(3).map { $0.family.color }
        guard sorted.count >= 3 else {
            let c1 = profile.dominantFamily.color
            let c2 = profile.secondFamily?.color ?? c1
            return [c1, c2, c1.opacity(0.6)]
        }
        return Array(sorted)
    }

    private var blobConfigs: [BlobConfig] {
        let c1 = blobColors[0]
        let c2 = blobColors.count > 1 ? blobColors[1] : blobColors[0]
        let c3 = blobColors.count > 2 ? blobColors[2] : blobColors[0]
        return [
            BlobConfig(color: c1,              size: 300, fromX: -80,  fromY: -120, toX: 60,   toY: -30,  toScale: 1.25, duration: 3.2, delay: 0),
            BlobConfig(color: c2,              size: 280, fromX: 90,   fromY: 70,   toX: -50,  toY: 100,  toScale: 0.85, duration: 2.8, delay: 0.3),
            BlobConfig(color: c3,              size: 280, fromX: 40,   fromY: -90,  toX: -70,  toY: 50,   toScale: 1.15, duration: 4.0, delay: 0.8),
            BlobConfig(color: c1.opacity(0.6), size: 200, fromX: -60,  fromY: 90,   toX: 70,   toY: -50,  toScale: 1.3,  duration: 2.4, delay: 0.5),
            BlobConfig(color: c2.opacity(0.5), size: 180, fromX: 0,    fromY: -50,  toX: -30,  toY: 80,   toScale: 0.9,  duration: 3.6, delay: 1.2),
            BlobConfig(color: c3.opacity(0.5), size: 180, fromX: -30,  fromY: 60,   toX: 50,   toY: -70,  toScale: 1.1,  duration: 3.0, delay: 0.9)
        ]
    }

    private var blobsLayer: some View {
        ZStack {
            ForEach(Array(blobConfigs.enumerated()), id: \.offset) { index, config in
                Circle()
                    .fill(config.color)
                    .frame(width: config.size, height: config.size)
                    .blur(radius: 55)
                    .blendMode(.screen)
                    .offset(x: animate ? config.toX : config.fromX, y: animate ? config.toY : config.fromY)
                    .scaleEffect(animate ? config.toScale : 1.0)
                    .animation(
                        .easeInOut(duration: config.duration).repeatForever(autoreverses: true).delay(config.delay),
                        value: animate
                    )
            }
        }
    }

    private func parseMarkdown(_ text: String) -> AttributedString {
        (try? AttributedString(markdown: text)) ?? AttributedString(text)
    }

    private struct BlobConfig {
        let color: Color
        let size: CGFloat
        let fromX, fromY, toX, toY: CGFloat
        let toScale: CGFloat
        let duration, delay: Double
    }
}

#Preview {
    ScentAuraView(profile: ScentProfile(
        dominantFamily: .woody,
        secondFamily: .oriental,
        topNotes: ["Bergamot", "Sandalwood", "Cedar"],
        familyDistribution: [.woody: 3, .oriental: 2, .fresh: 1],
        familyScores: [.woody: 12.0, .oriental: 8.0, .fresh: 3.0],
        topAccords: [
            AccordScore(name: "woody", score: 9, family: .woody),
            AccordScore(name: "oud", score: 6, family: .woody),
            AccordScore(name: "amber", score: 5, family: .oriental),
            AccordScore(name: "spicy", score: 3, family: .spicy),
            AccordScore(name: "earthy", score: 2, family: .herbal)
        ]
    ))
}
