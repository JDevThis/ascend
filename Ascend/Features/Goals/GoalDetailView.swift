import SwiftUI

struct GoalDetailView: View {
    let viewModel: GoalsViewModel
    let goal: Goal
    @State private var progressInput: String = ""
    @State private var isPresentingNewMilestone = false

    var body: some View {
        List {
            Section {
                VStack(spacing: AscendSpacing.sm) {
                    ProgressRingWithLabel(
                        progress: goal.progress,
                        title: goal.unit,
                        value: "\(Int(goal.currentValue))",
                        ringColor: goal.isOverdue ? AscendColor.warning : AscendColor.accent
                    )
                    .frame(width: 120, height: 120)
                    Text("Target: \(Int(goal.targetValue)) \(goal.unit) by \(goal.targetDate.formatted(date: .abbreviated, time: .omitted))")
                        .font(AscendFont.footnote())
                        .foregroundStyle(AscendColor.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, AscendSpacing.sm)

                if !goal.goalDescription.isEmpty {
                    Text(goal.goalDescription)
                        .font(AscendFont.body())
                        .foregroundStyle(AscendColor.textSecondary)
                }
            }

            Section("Update Progress") {
                HStack {
                    TextField("Current value", text: $progressInput)
                        .keyboardType(.decimalPad)
                    Button("Update") {
                        if let value = Double(progressInput) {
                            viewModel.updateProgress(goal, currentValue: value)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(AscendColor.accent)
                }
            }

            Section("Milestones") {
                ForEach(goal.sortedMilestones) { milestone in
                    HStack {
                        Image(systemName: milestone.isCompleted ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(milestone.isCompleted ? AscendColor.success : AscendColor.textSecondary)
                        VStack(alignment: .leading) {
                            Text(milestone.title)
                            Text("\(Int(milestone.targetValue)) \(goal.unit)")
                                .font(AscendFont.footnote())
                                .foregroundStyle(AscendColor.textSecondary)
                        }
                    }
                }
                Button("Add Milestone") {
                    isPresentingNewMilestone = true
                }
            }

            Section("Status") {
                Picker("Status", selection: Binding(
                    get: { goal.status },
                    set: { viewModel.setStatus(goal, status: $0) }
                )) {
                    ForEach(GoalStatus.allCases) { status in
                        Text(status.rawValue).tag(status)
                    }
                }
            }

            Section {
                Button("Delete Goal", role: .destructive) {
                    viewModel.delete(goal)
                }
            }
        }
        .navigationTitle(goal.title)
        .sheet(isPresented: $isPresentingNewMilestone) {
            NewMilestoneSheet(viewModel: viewModel, goal: goal)
        }
        .onAppear {
            progressInput = "\(Int(goal.currentValue))"
        }
    }
}

private struct NewMilestoneSheet: View {
    let viewModel: GoalsViewModel
    let goal: Goal
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var targetValue = ""

    var body: some View {
        NavigationStack {
            Form {
                TextField("Milestone title", text: $title)
                TextField("Target value", text: $targetValue)
                    .keyboardType(.decimalPad)
            }
            .navigationTitle("New Milestone")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if let value = Double(targetValue) {
                            viewModel.addMilestone(to: goal, title: title, targetValue: value)
                        }
                        dismiss()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty || Double(targetValue) == nil)
                }
            }
        }
    }
}
