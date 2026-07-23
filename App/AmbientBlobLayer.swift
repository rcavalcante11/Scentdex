import SwiftUI

/// Estado partilhado da migração de blobs entre tabs — vive uma única vez
/// no ContentView (como classe, sobrevive à recriação das views de cada
/// tab). Guarda só a data da última troca de tab e de que lado os blobs
/// devem entrar; a posição em si é sempre calculada a partir do tempo
/// decorrido, nunca guardada directamente.
@Observable
final class BlobTransitionState {
    var lastTransitionDate: Date = .distantPast
    var enterFromLeft: Bool = true

    func recordTransition(from oldTab: Int, to newTab: Int) {
        guard oldTab != newTab else { return }
        // A tab anterior estava para que lado? Se avançámos (índice subiu),
        // a tab anterior ficava à esquerda — os blobs vêm de lá, entrando
        // pela esquerda. Se recuámos, entram pela direita.
        enterFromLeft = newTab > oldTab
        lastTransitionDate = Date()
    }
}

/// Camada de blobs ambiente. Como a TabView cria um UIViewController opaco
/// por trás de cada tab (o que impede qualquer fundo comum "atrás" da
/// TabView de ser visível), esta view é instanciada uma vez DENTRO de cada
/// tab — mas todas partilham o mesmo `BlobTransitionState`, por isso a
/// migração entre tabs continua a sentir-se como uma coisa só, não três
/// animações independentes.
struct AmbientBlobLayer: View {
    let profile: ScentProfile?
    var transitionState: BlobTransitionState

    // MARK: - Body
    var body: some View {
        TimelineView(.animation) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate
            let elapsed = timeline.date.timeIntervalSince(transitionState.lastTransitionDate)

            ZStack {
                ForEach(Array(blobConfigs.enumerated()), id: \.offset) { index, config in
                    blobView(config: config, t: t, elapsed: elapsed)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .compositingGroup()
        }
    }

    @ViewBuilder
    private func blobView(config: BlobConfig, t: TimeInterval, elapsed: TimeInterval) -> some View {
        let phase = t * config.speed + config.phaseOffset
        // Lemniscata vertical: x oscila ao dobro da frequência de y,
        // criando o cruzamento ao centro típico do "8" (do topo ao
        // fundo do ecrã).
        let organicX = config.ampX * sin(2 * phase)
        let organicY = config.ampY * sin(phase)
        let scale = config.baseScale + config.scaleAmp * sin(phase * 0.5)
        let migrationX = migrationOffsetX(for: config, elapsed: elapsed)

        Circle()
            .fill(config.color)
            .frame(width: config.size, height: config.size)
            .blur(radius: 45)
            .blendMode(.screen)
            .offset(x: organicX + migrationX, y: organicY)
            .scaleEffect(scale)
    }

    // MARK: - Migration math
    /// Calcula o deslocamento horizontal extra causado pela migração entre
    /// tabs, puramente a partir do tempo decorrido desde a última troca —
    /// sem estado próprio guardado, por isso funciona igual em qualquer
    /// instância desta view, em qualquer tab.
    private func migrationOffsetX(for config: BlobConfig, elapsed: TimeInterval) -> CGFloat {
        let travelDistance: CGFloat = 900
        let startX: CGFloat = transitionState.enterFromLeft ? -travelDistance : travelDistance

        guard elapsed >= 0 else { return 0 }
        if elapsed < config.flightDelay { return startX }

        let progress = min(1, (elapsed - config.flightDelay) / config.flightDuration)
        guard progress < 1 else { return 0 }

        let eased = 1 - pow(1 - progress, 3) // ease-out cúbico
        return startX * (1 - eased)
    }

    // MARK: - Colors
    private var blobColors: [Color] {
        guard let profile else {
            return [.gray, .gray.opacity(0.6), .gray.opacity(0.4)]
        }
        let sorted = profile.topAccords.prefix(3).map { $0.family.color }
        guard sorted.count >= 3 else {
            let c1 = profile.dominantFamily.color
            let c2 = profile.secondFamily?.color ?? c1
            return [c1, c2, c1.opacity(0.6)]
        }
        return Array(sorted)
    }

    // MARK: - Configs
    private struct BlobConfig {
        let color: Color
        let size: CGFloat
        let ampX: CGFloat
        let ampY: CGFloat
        let baseScale: CGFloat
        let scaleAmp: CGFloat
        let speed: Double        // radianos por segundo — velocidade orgânica
        let phaseOffset: Double  // posição inicial no laço, espalha os blobs
        let flightDuration: Double // duração da migração entre tabs
        let flightDelay: Double    // atraso antes de começar a migrar
    }

    private var blobConfigs: [BlobConfig] {
        let c1 = blobColors[0]
        let c2 = blobColors.count > 1 ? blobColors[1] : blobColors[0]
        let c3 = blobColors.count > 2 ? blobColors[2] : blobColors[0]

        return [
            BlobConfig(color: c1,              size: 380, ampX: 145, ampY: 390, baseScale: 1.05, scaleAmp: 0.35, speed: 0.72, phaseOffset: 0,                 flightDuration: 1.05, flightDelay: 0.00),
            BlobConfig(color: c2,              size: 340, ampX: 130, ampY: 375, baseScale: 1.0,  scaleAmp: 0.3,  speed: 0.66, phaseOffset: .pi / 3,           flightDuration: 1.30, flightDelay: 0.22),
            BlobConfig(color: c3,              size: 340, ampX: 135, ampY: 385, baseScale: 1.05, scaleAmp: 0.32, speed: 0.78, phaseOffset: 2 * .pi / 3,       flightDuration: 0.95, flightDelay: 0.10),
            BlobConfig(color: c1.opacity(0.6), size: 260, ampX: 115, ampY: 360, baseScale: 1.0,  scaleAmp: 0.4,  speed: 0.84, phaseOffset: .pi,               flightDuration: 1.45, flightDelay: 0.34),
            BlobConfig(color: c2.opacity(0.5), size: 230, ampX: 110, ampY: 340, baseScale: 0.95, scaleAmp: 0.28, speed: 0.60, phaseOffset: 4 * .pi / 3,       flightDuration: 1.15, flightDelay: 0.15),
            BlobConfig(color: c3.opacity(0.5), size: 230, ampX: 125, ampY: 365, baseScale: 1.0,  scaleAmp: 0.3,  speed: 0.90, phaseOffset: 5 * .pi / 3,       flightDuration: 1.25, flightDelay: 0.28)
        ]
    }
}
