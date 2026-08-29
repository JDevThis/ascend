import SwiftUI
import Charts

private struct WeeklyVolumePoint: Identifiable {
    let id: Int
    let volume: Double
}

struct WorkoutAnalyticsView: View {
    let viewModel: WorkoutsViewModel

    private var last8WeeksVolume: [WeeklyVolumePoint] {
        (0..<8).reversed().map { WeeklyVolumePoint(id: $0, volume: viewModel.weeklyVolume(weeksBack: $0)) }
    }

    var body: some View {
        List {
            Section("This Week") {
                HStack {
                    StatTile(title: "Weekly Volume", value: "\(Int(viewModel.weeklyVolume())) lb", systemImage: "scalemass.fill")
                    StatTile(title: "Monthly Volume", value: "\(Int(viewModel.monthlyVolume())) lb", systemImage: "calendar", tint: AscendColor.accentSecondary)
                }
                .listRowInsets(EdgeInsets())
                .padding(.vertical, 4)
            }

            Section("Volume Trend") {
                Chart(last8WeeksVolume) { entry in
                    BarMark(
                        x: .value("Week", -entry.id),
                        y: .value("Volume", entry.volume)
                    )
                    .foregroundStyle(AscendColor.accent)
                    .cornerRadius(4)
                }
                .frame(height: 160)
                .chartXAxis(.hidden)
            }

            Section("Consistency") {
                HStack {
                    ProgressRing(progress: viewModel.consistencyScore(), lineWidth: 8)
                        .frame(width: 50, height: 50)
                    Text("\(Int(viewModel.consistencyScore() * 100))% of the last 8 weeks had a logged workout")
                        .font(AscendFont.footnote())
                        .foregroundStyle(AscendColor.textSecondary)
                }
            }

            Section("Personal Records") {
                let prs = viewModel.personalRecords()
                if prs.isEmpty {
                    Text("Complete sets to start tracking PRs.")
                        .foregroundStyle(AscendColor.textSecondary)
                } else {
                    ForEach(prs) { record in
                        HStack {
                            Text(record.exercise.name)
                            Spacer()
                            Text("\(Int(record.estimatedOneRepMax)) lb")
                                .foregroundStyle(AscendColor.accent)
                                .fontWeight(.semibold)
                        }
                    }
                }
            }
        }
        .navigationTitle("Analytics")
    }
}
