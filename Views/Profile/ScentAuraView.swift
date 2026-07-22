import SwiftUI

struct ScentAuraView: View {

    // MARK: - Properties
    let profile: ScentProfile
    @State private var viewModel = ScentAuraViewModel()
    @State private var descriptionExpanded = false
    @State private var fingerprintExpanded = false
    @State private var radarAnimated = false

    private let descriptionLineLimit = 4

    // MARK: - Body
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            blobsLayer
                .ignoresSafeArea()

            // Escurecimento global e contínuo — cobre o ecrã todo (não só o
            // header), para não haver fronteira visível entre secções.
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

            ScrollView {
                VStack(spacing: 0) {

                    ZStack(alignment: .bottom) {

                        VStack(alignment: .leading, spacing: 0) {
                            Spacer().frame(height: 120)

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

                            descriptionSection
                                .padding(.horizontal, 28)

                            auraFingerprintSection
                                .padding(.horizontal, 28)
                                .padding(.top, 16)

                            Spacer().frame(height: 40)
                        }
                    }
                    .frame(minHeight: 500)

                    VStack(alignment: .leading, spacing: 24) {
                        RecommendationCarouselView(profile: profile)
                    }
                    .padding(24)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(.white.opacity(0.15), lineWidth: 0.5)
                    )
                    .padding(.horizontal, 24)
                }
            }
            .refreshable {
                await viewModel.refresh(for: profile)
            }
            .tint(.white)
            .scrollContentBackground(.hidden)
        }
        .ignoresSafeArea(edges: .top)
        .onAppear {
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
                    HStack(spacing: -4) {
                        ForEach(0..<3, id: \.self) { i in
                            Circle()
                                .fill(blobColors[i < blobColors.count ? i : 0])
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
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(.white.opacity(0.25), lineWidth: 0.5)
                )
            }

            if fingerprintExpanded {
                VStack(alignment: .leading, spacing: 16) {

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

                    Text("Accord Breakdown")
                        .font(.caption)
                        .fontWeight(.medium)
                        .tracking(1.5)
                        .foregroundStyle(.white.opacity(0.4))

                    HStack(alignment: .center, spacing: 16) {
                        RadarView(
                            accords: profile.topAccords,
                            animated: radarAnimated
                        )
                        .frame(width: 100, height: 100)

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
            .background(.ultraThinMaterial, in: Capsule())
            .foregroundStyle(.white)
            .overlay(
                Capsule().stroke(.white.opacity(0.3), lineWidth: 0.5)
            )
    }

    private var topAccordTags: [String] {
        profile.topAccords.prefix(3).map { $0.name }
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

        // 6 blobs distribuídos uniformemente pelo mesmo laço em "8" (espaçados
        // de 60° em 60°, para nunca ficarem todos amontoados no mesmo lóbulo),
        // cada um com velocidade ligeiramente diferente para um movimento mais
        // orgânico em vez de perfeitamente sincronizado.
        return [
            BlobConfig(color: c1,              size: 380, ampX: 145, ampY: 390, baseScale: 1.05, scaleAmp: 0.35, speed: 0.72, phaseOffset: 0),
            BlobConfig(color: c2,              size: 340, ampX: 130, ampY: 375, baseScale: 1.0,  scaleAmp: 0.3,  speed: 0.66, phaseOffset: .pi / 3),
            BlobConfig(color: c3,              size: 340, ampX: 135, ampY: 385, baseScale: 1.05, scaleAmp: 0.32, speed: 0.78, phaseOffset: 2 * .pi / 3),
            BlobConfig(color: c1.opacity(0.6), size: 260, ampX: 115, ampY: 360, baseScale: 1.0,  scaleAmp: 0.4,  speed: 0.84, phaseOffset: .pi),
            BlobConfig(color: c2.opacity(0.5), size: 230, ampX: 110, ampY: 340, baseScale: 0.95, scaleAmp: 0.28, speed: 0.60, phaseOffset: 4 * .pi / 3),
            BlobConfig(color: c3.opacity(0.5), size: 230, ampX: 125, ampY: 365, baseScale: 1.0,  scaleAmp: 0.3,  speed: 0.90, phaseOffset: 5 * .pi / 3)
        ]
    }

    private var blobsLayer: some View {
        TimelineView(.animation) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate

            ZStack {
                ForEach(Array(blobConfigs.enumerated()), id: \.offset) { index, config in
                    let phase = t * config.speed + config.phaseOffset
                    // Lemniscata vertical: x oscila ao dobro da frequência de y,
                    // criando o cruzamento ao centro típico do símbolo do infinito
                    // (aqui na vertical, tipo o número 8, do header até ao fundo).
                    let x = config.ampX * sin(2 * phase)
                    let y = config.ampY * sin(phase)
                    let scale = config.baseScale + config.scaleAmp * sin(phase * 0.5)

                    Circle()
                        .fill(config.color)
                        .frame(width: config.size, height: config.size)
                        .blur(radius: 45)
                        .blendMode(.screen)
                        .offset(x: x, y: y)
                        .scaleEffect(scale)
                }
            }
            .compositingGroup()
        }
    }

    private func parseMarkdown(_ text: String) -> AttributedString {
        (try? AttributedString(markdown: text)) ?? AttributedString(text)
    }

    private func barRatio(_ score: Double) -> CGFloat {
        let max = profile.topAccords.first?.score ?? 1
        return CGFloat(score / max)
    }

    private struct BlobConfig {
        let color: Color
        let size: CGFloat
        let ampX: CGFloat
        let ampY: CGFloat
        let baseScale: CGFloat
        let scaleAmp: CGFloat
        let speed: Double       // radianos por segundo — velocidade ao longo do laço
        let phaseOffset: Double // posição inicial no laço (radianos), espalha os blobs
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
            
        ],
        wishlistAccords: []
    ))
}
