import SwiftUI

struct ActiveWorkoutView: View {
    let day: WorkoutDay?
    @Environment(\.modelContext) private var modelContext
    @Environment(AppContainer.self) private var container
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: ActiveWorkoutViewModel?

    var body: some View {
        Group {
            if let viewModel {
                content(viewModel: viewModel)
            } else {
                ProgressView()
            }
        }
        .onAppear {
            if viewModel == nil {
                viewModel = ActiveWorkoutViewModel(
                    context: modelContext,
                    day: day,
                    notificationService: container.notificationService,
                    healthKitService: container.healthKitService
                )
                viewModel?.start()
            }
        }
    }

    @ViewBuilder
    private func content(viewModel: ActiveWorkoutViewModel) -> some View {
        List {
            Section {
                HStack {
                    Text(formattedElapsed(viewModel.elapsed))
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundStyle(AscendColor.textPrimary)
                    Spacer()
                    Button(viewModel.isRunning ? "Pause" : "Resume") {
                        viewModel.isRunning ? viewModel.pause() : viewModel.start()
                    }
                    .buttonStyle(.bordered)
                }

                if viewModel.isResting {
                    HStack {
                        Label("Resting", systemImage: "timer")
                        Spacer()
                        Text(formattedElapsed(viewModel.restRemaining))
                            .font(.system(.body, design: .monospaced))
                        Button("Skip") { viewModel.skipRest() }
                            .buttonStyle(.bordered)
                    }
                }
            }

            let groupedSets = Dictionary(grouping: viewModel.session.sets ?? [], by: { $0.exercise?.persistentModelID })
            ForEach((viewModel.session.sets ?? []).compactMap(\.exercise).uniqued(), id: \.persistentModelID) { exercise in
                Section(exercise.name) {
                    ForEach(groupedSets[exercise.persistentModelID] ?? []) { set in
                        SetRow(set: set, onToggle: { viewModel.toggleCompleted(set) })
                    }
                }
            }

            Section {
                Toggle("Sync to Apple Health", isOn: Binding(
                    get: { viewModel.syncToHealth },
                    set: { viewModel.syncToHealth = $0 }
                ))
            }
        }
        .navigationTitle(day?.name ?? "Workout")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Finish") {
                    Task {
                        await viewModel.finish()
                        dismiss()
                    }
                }
            }
        }
    }

    private func formattedElapsed(_ interval: TimeInterval) -> String {
        let minutes = Int(interval) / 60
        let seconds = Int(interval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

private struct SetRow: View {
    @Bindable var set: ExerciseSet
    let onToggle: () -> Void

    var body: some View {
        HStack {
            Text("Set \(set.order + 1)")
                .foregroundStyle(AscendColor.textSecondary)
                .frame(width: 56, alignment: .leading)
            TextField("Reps", value: $set.reps, format: .number)
                .keyboardType(.numberPad)
                .frame(width: 50)
            Text("x")
                .foregroundStyle(AscendColor.textSecondary)
            TextField("Weight", value: $set.weight, format: .number)
                .keyboardType(.decimalPad)
                .frame(width: 60)
            Spacer()
            Button(action: onToggle) {
                Image(systemName: set.completed ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(set.completed ? AscendColor.success : AscendColor.textSecondary)
                    .font(.system(size: 22))
            }
            .buttonStyle(.plain)
        }
    }
}

private extension Array where Element: AnyObject {
    func uniqued() -> [Element] {
        var seen = Set<ObjectIdentifier>()
        return filter { seen.insert(ObjectIdentifier($0)).inserted }
    }
}
