//
//  RadarView.swift
//  Scentdex
//
//  Created by macbook on 19/06/2026.
//

import SwiftUI

struct RadarView: View {
    let accords: [AccordScore]
    let animated: Bool

    var body: some View {
        Canvas { context, size in
            let cx = size.width / 2
            let cy = size.height / 2
            let maxR = min(cx, cy) - 8
            let n = min(accords.count, 6)
            guard n > 0 else { return }
            let maxScore = accords.first?.score ?? 1

            drawGrid(context: context, cx: cx, cy: cy, maxR: maxR, n: n)
            drawAxes(context: context, cx: cx, cy: cy, maxR: maxR, n: n)
            drawPolygon(context: context, cx: cx, cy: cy, maxR: maxR, n: n, maxScore: maxScore)
            drawDots(context: context, cx: cx, cy: cy, maxR: maxR, n: n, maxScore: maxScore)
        }
        .animation(.easeOut(duration: 0.8), value: animated)
    }

    private func drawGrid(context: GraphicsContext, cx: Double, cy: Double, maxR: Double, n: Int) {
        for ring in 1...3 {
            let r = (Double(ring) / 3.0) * maxR
            var path = Path()
            for i in 0..<n {
                let angle = (Double(i) / Double(n)) * .pi * 2 - .pi / 2
                let x = cx + cos(angle) * r
                let y = cy + sin(angle) * r
                if i == 0 { path.move(to: CGPoint(x: x, y: y)) }
                else { path.addLine(to: CGPoint(x: x, y: y)) }
            }
            path.closeSubpath()
            context.stroke(path, with: .color(.white.opacity(0.08)), lineWidth: 0.5)
        }
    }

    private func drawAxes(context: GraphicsContext, cx: Double, cy: Double, maxR: Double, n: Int) {
        for i in 0..<n {
            let angle = (Double(i) / Double(n)) * .pi * 2 - .pi / 2
            var path = Path()
            path.move(to: CGPoint(x: cx, y: cy))
            path.addLine(to: CGPoint(x: cx + cos(angle) * maxR, y: cy + sin(angle) * maxR))
            context.stroke(path, with: .color(.white.opacity(0.08)), lineWidth: 0.5)
        }
    }

    private func drawPolygon(context: GraphicsContext, cx: Double, cy: Double, maxR: Double, n: Int, maxScore: Double) {
        let animScale = animated ? 1.0 : 0.0
        var poly = Path()
        for i in 0..<n {
            let angle = (Double(i) / Double(n)) * .pi * 2 - .pi / 2
            let r = (accords[i].score / maxScore) * maxR * animScale
            let x = cx + cos(angle) * r
            let y = cy + sin(angle) * r
            if i == 0 { poly.move(to: CGPoint(x: x, y: y)) }
            else { poly.addLine(to: CGPoint(x: x, y: y)) }
        }
        poly.closeSubpath()
        let color = accords.first?.family.color ?? .white
        context.fill(poly, with: .color(color.opacity(0.2)))
        context.stroke(poly, with: .color(color.opacity(0.8)), lineWidth: 1.5)
    }

    private func drawDots(context: GraphicsContext, cx: Double, cy: Double, maxR: Double, n: Int, maxScore: Double) {
        let animScale = animated ? 1.0 : 0.0
        for i in 0..<n {
            let angle = (Double(i) / Double(n)) * .pi * 2 - .pi / 2
            let r = (accords[i].score / maxScore) * maxR * animScale
            let x = cx + cos(angle) * r
            let y = cy + sin(angle) * r
            let dot = Path(ellipseIn: CGRect(x: x - 3, y: y - 3, width: 6, height: 6))
            context.fill(dot, with: .color(accords[i].family.color))
        }
    }
}
