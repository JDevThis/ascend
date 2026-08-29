import SwiftUI
import Charts

struct ExerciseHistoryView: View {
    let viewModel: WorkoutsViewModel
    let exercise: Exercise

    private var sets: [ExerciseSet] { viewModel.history(for: exercise) }

    private var bestSet: ExerciseSet? {
        sets.max { $0.weight * (1 + Double($0.reps) / 30.0) < $1.weight * (1 + Double($1.reps) / 30.0) }
    }

    var body: some View {
        List {
            if let bestSet {
                Section("Personal Record") {
                    HStack {
                        Text("Est. 1RM")
                        Spacer()
                        Text("\(Int(bestSet.weight * (1 + Double(bestSet.reps) / 30.0))) lb")
                            .fontWeight(.semibold)
                    }
                    HStack {
                        Text("Best Set")
                        Spacer()
                        Text("\(Int(bestSet.weight)) lb x \(bestSet.reps)")
                            .foregroundStyle(AscendColor.textSecondary)
                    }
                }
            }

            if !sets.isEmpty {
                Section("Progression") {
                    Chart(sets.reversed()) { set in
                        LineMark(
                            x: .value("Date", set.session?.date ?? .now),
                            y: .value("Weight", set.weight)
                        )
                        .foregroundStyle(AscendColor.accent)
                    }
                    .frame(height: 140)
                }
            }

            Section("History") {
                if sets.isEmpty {
                    Text("No completed sets logged yet.")
                        .foregroundStyle(AscendColor.textSecondary)
                } else {
                    ForEach(sets) { set in
                        HStack {
                            Text(set.session?.date.formatted(date: .abbreviated, time: .omitted) ?? "")
                            Spacer()
                            Text("\(Int(set.weight)) lb x \(set.reps)")
                                .foregroundStyle(AscendColor.textSecondary)
                        }
                    }
                }
            }
        }
        .navigationTitle(exercise.name)
    }
}
