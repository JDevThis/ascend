import SwiftUI

struct WorkoutHistoryView: View {
    let viewModel: WorkoutsViewModel

    var body: some View {
        List {
            if viewModel.recentSessions.isEmpty {
                EmptyStateView(
                    systemImage: "clock.arrow.circlepath",
                    title: "No sessions yet",
                    message: "Start a workout from an active program to see it here."
                )
            } else {
                ForEach(viewModel.recentSessions) { session in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(session.plannedDay?.name ?? "Workout")
                                .font(AscendFont.body())
                            Spacer()
                            Text(session.date.formatted(date: .abbreviated, time: .omitted))
                                .font(AscendFont.footnote())
                                .foregroundStyle(AscendColor.textSecondary)
                        }
                        HStack {
                            Label("\(Int(session.duration / 60)) min", systemImage: "clock")
                            Spacer()
                            Label("\(Int(session.totalVolume)) lb volume", systemImage: "scalemass")
                        }
                        .font(AscendFont.footnote())
                        .foregroundStyle(AscendColor.textSecondary)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle("Workout History")
    }
}
