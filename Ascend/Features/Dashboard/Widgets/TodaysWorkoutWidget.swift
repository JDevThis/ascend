import SwiftUI

struct TodaysWorkoutWidget: View {
    let viewModel: DashboardViewModel

    var body: some View {
        AscendCard {
            AscendCardHeader(title: "Today's Workout", systemImage: "dumbbell.fill")

            if let session = viewModel.todaysSession {
                HStack {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundStyle(AscendColor.success)
                    Text(session.plannedDay?.name ?? "Workout logged")
                        .font(AscendFont.body())
                        .foregroundStyle(AscendColor.textPrimary)
                    Spacer()
                    Text(formattedDuration(session.duration))
                        .font(AscendFont.footnote())
                        .foregroundStyle(AscendColor.textSecondary)
                }
            } else if let day = viewModel.nextPlannedDay {
                HStack {
                    VStack(alignment: .leading) {
                        Text(day.name)
                            .font(AscendFont.body())
                            .foregroundStyle(AscendColor.textPrimary)
                        Text("\(day.sortedExercises.count) exercises planned")
                            .font(AscendFont.footnote())
                            .foregroundStyle(AscendColor.textSecondary)
                    }
                    Spacer()
                    NavigationLink("Start") {
                        ActiveWorkoutView(day: day)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(AscendColor.accent)
                }
            } else {
                Text("No active program. Create one in the Workouts tab.")
                    .font(AscendFont.footnote())
                    .foregroundStyle(AscendColor.textSecondary)
            }
        }
    }

    private func formattedDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration / 60)
        return "\(minutes) min"
    }
}
