import SwiftUI
import SwiftData

struct ProgramDetailView: View {
    let viewModel: WorkoutsViewModel
    let program: WorkoutProgram
    @Environment(\.modelContext) private var modelContext
    @State private var isPresentingNewDay = false

    var body: some View {
        List {
            Section {
                Text(program.programDescription.isEmpty ? "No description" : program.programDescription)
                    .foregroundStyle(AscendColor.textSecondary)
                if !program.isActive {
                    Button("Set as Active Program") {
                        viewModel.setActive(program)
                    }
                }
            }

            Section("Days") {
                if program.sortedDays.isEmpty {
                    Text("No days yet. Tap + to add one.")
                        .foregroundStyle(AscendColor.textSecondary)
                } else {
                    ForEach(program.sortedDays) { day in
                        NavigationLink {
                            WorkoutDayEditorView(viewModel: viewModel, day: day)
                        } label: {
                            VStack(alignment: .leading) {
                                Text(day.name).font(AscendFont.body())
                                Text("\(day.sortedExercises.count) exercises")
                                    .font(AscendFont.footnote())
                                    .foregroundStyle(AscendColor.textSecondary)
                            }
                        }
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            modelContext.delete(program.sortedDays[index])
                        }
                        try? modelContext.save()
                        viewModel.refresh()
                    }
                }
            }
        }
        .navigationTitle(program.name)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isPresentingNewDay = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $isPresentingNewDay) {
            NewDaySheet(program: program, viewModel: viewModel)
        }
    }
}

private struct NewDaySheet: View {
    let program: WorkoutProgram
    let viewModel: WorkoutsViewModel
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""

    var body: some View {
        NavigationStack {
            Form {
                TextField("Day name (e.g. Push Day)", text: $name)
            }
            .navigationTitle("New Day")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let day = WorkoutDay(name: name, order: program.sortedDays.count)
                        day.program = program
                        modelContext.insert(day)
                        try? modelContext.save()
                        viewModel.refresh()
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}
