import SwiftUI
import SwiftData

struct WorkoutDayEditorView: View {
    let viewModel: WorkoutsViewModel
    let day: WorkoutDay
    @Environment(\.modelContext) private var modelContext
    @State private var isPresentingExercisePicker = false

    var body: some View {
        List {
            Section("Exercises") {
                if day.sortedExercises.isEmpty {
                    Text("No exercises assigned yet.")
                        .foregroundStyle(AscendColor.textSecondary)
                } else {
                    ForEach(day.sortedExercises) { assignment in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(assignment.exercise?.name ?? "Unknown")
                                    .font(AscendFont.body())
                                Text("\(assignment.targetSets) x \(assignment.targetReps)")
                                    .font(AscendFont.footnote())
                                    .foregroundStyle(AscendColor.textSecondary)
                            }
                            Spacer()
                            Stepper("", value: Binding(
                                get: { assignment.targetSets },
                                set: { assignment.targetSets = $0; try? modelContext.save() }
                            ), in: 1...10)
                            .labelsHidden()
                        }
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            modelContext.delete(day.sortedExercises[index])
                        }
                        try? modelContext.save()
                        viewModel.refresh()
                    }
                }
            }
        }
        .navigationTitle(day.name)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isPresentingExercisePicker = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $isPresentingExercisePicker) {
            ExercisePickerSheet(viewModel: viewModel, day: day)
        }
    }
}

private struct ExercisePickerSheet: View {
    let viewModel: WorkoutsViewModel
    let day: WorkoutDay
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List(viewModel.exercises) { exercise in
                Button {
                    let assignment = WorkoutDayExercise(exercise: exercise, order: day.sortedExercises.count)
                    assignment.day = day
                    modelContext.insert(assignment)
                    try? modelContext.save()
                    viewModel.refresh()
                    dismiss()
                } label: {
                    HStack {
                        Text(exercise.name)
                        Spacer()
                        Text(exercise.muscleGroup.rawValue)
                            .font(AscendFont.footnote())
                            .foregroundStyle(AscendColor.textSecondary)
                    }
                }
            }
            .navigationTitle("Add Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}
