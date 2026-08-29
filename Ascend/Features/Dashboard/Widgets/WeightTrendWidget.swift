import SwiftUI
import Charts

struct WeightTrendWidget: View {
    let viewModel: DashboardViewModel

    var body: some View {
        AscendCard {
            AscendCardHeader(title: "Weight Trend", systemImage: "chart.line.downtrend.xyaxis")

            if viewModel.recentWeightEntries.isEmpty {
                Text("Log your weight from the Profile tab to see a trend.")
                    .font(AscendFont.footnote())
                    .foregroundStyle(AscendColor.textSecondary)
            } else {
                Chart(viewModel.recentWeightEntries) { entry in
                    if let weight = entry.weightLb {
                        LineMark(
                            x: .value("Date", entry.date),
                            y: .value("Weight", weight)
                        )
                        .foregroundStyle(AscendColor.accent)
                        .interpolationMethod(.catmullRom)
                        AreaMark(
                            x: .value("Date", entry.date),
                            y: .value("Weight", weight)
                        )
                        .foregroundStyle(AscendColor.accent.opacity(0.12))
                        .interpolationMethod(.catmullRom)
                    }
                }
                .frame(height: 120)
                .chartXAxis(.hidden)
            }
        }
    }
}
