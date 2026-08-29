import SwiftUI

struct ExerciseLibraryView: View {
    let viewModel: WorkoutsViewModel
    @State private var isPresentingNewExercise = false

    private var groupedByMuscle: [MuscleGroup: [Exercise]] {
        Dictionary(grouping: viewModel.exercises, by: \.muscleGroup)
    }

    var body: some View {
        List {
            ForEach(MuscleGroup.allCases) { group in
                if let exercises = groupedByMuscle[group], !exercises.isEmpty {
                    Section(group.rawValue) {
                        ForEach(exercises) { exercise in
                            NavigationLink {
                                ExerciseHistoryView(viewModel: viewModel, exercise: exercise)
                            } label: {
                                VStack(alignment: .leading) {
                                    Text(exercise.name).font(AscendFont.body())
                                    if !exercise.notes.isEmpty {
                                        Text(exercise.notes)
                                            .font(AscendFont.footnote())
                                            .foregroundStyle(AscendColor.textSecondary)
                                    }
                                }
                            }
                        }
                        .onDelete { indexSet in
                            for index in indexSet {
                                viewModel.deleteExercise(exercises[index])
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Exercise Library")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isPresentingNewExercise = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $isPresentingNewExercise) {
            NewExerciseSheet(viewModel: viewModel)
        }
    }
}

private struct NewExerciseSheet: View {
    let viewModel: WorkoutsViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var muscleGroup: MuscleGroup = .other
    @State private var notes = ""

    var body: some View {
        NavigationStack {
            Form {
                TextField("Name", text: $name)
                Picker("Muscle Group", selection: $muscleGroup) {
                    ForEach(MuscleGroup.allCases) { group in
                        Text(group.rawValue).tag(group)
                    }
                }
                TextField("Notes", text: $notes, axis: .vertical)
            }
            .navigationTitle("New Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.createExercise(name: name, muscleGroup: muscleGroup, notes: notes)
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}
