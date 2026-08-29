import SwiftUI

struct ScoreStreakWidget: View {
    let viewModel: DashboardViewModel

    var body: some View {
        HStack(spacing: AscendSpacing.md) {
            AscendCard {
                HStack {
                    ProgressRingWithLabel(
                        progress: Double(viewModel.dailyScore) / 100.0,
                        title: "Score",
                        value: "\(viewModel.dailyScore)"
                    )
                    .frame(width: 84, height: 84)
                    Spacer()
                }
            }
            AscendCard {
                VStack(alignment: .leading, spacing: AscendSpacing.xxs) {
                    Image(systemName: "flame.fill")
                        .foregroundStyle(AscendColor.warning)
                        .font(.system(size: 22))
                    Text("\(viewModel.currentStreak)")
                        .font(AscendFont.statValue())
                        .foregroundStyle(AscendColor.textPrimary)
                    Text("day streak")
                        .font(AscendFont.caption())
                        .foregroundStyle(AscendColor.textSecondary)
                }
            }
        }
    }
}
