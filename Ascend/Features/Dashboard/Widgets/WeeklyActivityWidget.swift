import SwiftUI
import Charts

struct WeeklyActivityWidget: View {
    let viewModel: DashboardViewModel

    private struct DayScore: Identifiable {
        let id: Int
        let label: String
        let score: Int
    }

    private var data: [DayScore] {
        let calendar = Calendar.current
        return viewModel.weeklyScores.enumerated().map { index, score in
            let offset = viewModel.weeklyScores.count - 1 - index
            let date = calendar.date(byAdding: .day, value: -offset, to: .now) ?? .now
            return DayScore(id: index, label: date.formatted(.dateTime.weekday(.narrow)), score: score)
        }
    }

    var body: some View {
        AscendCard {
            AscendCardHeader(title: "Weekly Activity", systemImage: "chart.bar.fill")

            Chart(data) { day in
                BarMark(
                    x: .value("Day", day.label),
                    y: .value("Score", day.score)
                )
                .foregroundStyle(day.score >= 50 ? AscendColor.accent : AscendColor.surfaceSecondary)
                .cornerRadius(4)
            }
            .frame(height: 120)
            .chartYScale(domain: 0...100)
        }
    }
}
