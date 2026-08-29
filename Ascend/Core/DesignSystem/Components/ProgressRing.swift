import SwiftUI

/// Circular progress indicator used for scores, goals, and habit completion.
struct ProgressRing: View {
    let progress: Double // 0...1
    var lineWidth: CGFloat = 10
    var ringColor: Color = AscendColor.accent
    var trackColor: Color = AscendColor.surfaceSecondary

    var body: some View {
        ZStack {
            Circle()
                .stroke(trackColor, lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: max(0.001, min(1, progress)))
                .stroke(ringColor, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.6), value: progress)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(Int(progress * 100)) percent")
    }
}

struct ProgressRingWithLabel: View {
    let progress: Double
    let title: String
    let value: String
    var ringColor: Color = AscendColor.accent

    var body: some View {
        ZStack {
            ProgressRing(progress: progress, ringColor: ringColor)
            VStack(spacing: 2) {
                Text(value)
                    .font(AscendFont.statValue())
                    .foregroundStyle(AscendColor.textPrimary)
                    .minimumScaleFactor(0.6)
                Text(title)
                    .font(AscendFont.caption())
                    .foregroundStyle(AscendColor.textSecondary)
            }
        }
    }
}
