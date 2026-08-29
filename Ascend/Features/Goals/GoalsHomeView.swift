import SwiftUI

struct GoalsHomeView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: GoalsViewModel?
    @State private var isPresentingNewGoal = false

    var body: some View {
        NavigationStack {
            Group {
                if let viewModel {
                    if viewModel.goals.isEmpty {
                        EmptyStateView(
                            systemImage: "target",
                            title: "No goals yet",
                            message: "Set a long-term or short-term goal to start tracking progress.",
                            actionTitle: "Add Goal"
                        ) {
                            isPresentingNewGoal = true
                        }
                    } else {
                        List {
                            Section {
                                HStack {
                                    StatTile(title: "Completion Rate", value: "\(Int(viewModel.completionRate * 100))%", systemImage: "checkmark.seal.fill")
                                    StatTile(title: "On Track", value: "\(viewModel.onTrackCount)", systemImage: "arrow.up.right", tint: AscendColor.success)
                                    StatTile(title: "Behind", value: "\(viewModel.behindScheduleCount)", systemImage: "exclamationmark.triangle.fill", tint: AscendColor.warning)
                                }
                                .listRowInsets(EdgeInsets())
                                .padding(.vertical, 4)
                            }

                            Section("Active Goals") {
                                ForEach(viewModel.activeGoals) { goal in
                                    NavigationLink {
                                        GoalDetailView(viewModel: viewModel, goal: goal)
                                    } label: {
                                        GoalRow(goal: goal)
                                    }
                                }
                            }

                            if !viewModel.archivedGoals.isEmpty {
                                Section("Archived") {
                                    ForEach(viewModel.archivedGoals) { goal in
                                        NavigationLink {
                                            GoalDetailView(viewModel: viewModel, goal: goal)
                                        } label: {
                                            GoalRow(goal: goal)
                                        }
                                    }
                                }
                            }
                        }
                        .listStyle(.insetGrouped)
                    }
                } else {
                    ProgressView()
                }
            }
            .navigationTitle("Goals")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isPresentingNewGoal = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $isPresentingNewGoal) {
                if let viewModel {
                    GoalEditorView(viewModel: viewModel)
                }
            }
            .onAppear {
                if viewModel == nil {
                    viewModel = GoalsViewModel(context: modelContext)
                } else {
                    viewModel?.refresh()
                }
            }
        }
    }
}

private struct GoalRow: View {
    let goal: Goal

    var body: some View {
        HStack(spacing: AscendSpacing.sm) {
            Image(systemName: goal.category.symbolName)
                .foregroundStyle(AscendColor.accentSecondary)
                .frame(width: 28)
            VStack(alignment: .leading, spacing: 4) {
                Text(goal.title).font(AscendFont.body())
                ProgressView(value: goal.progress)
                    .tint(goal.isOverdue ? AscendColor.warning : AscendColor.accent)
                Text("\(Int(goal.currentValue))/\(Int(goal.targetValue)) \(goal.unit)")
                    .font(AscendFont.footnote())
                    .foregroundStyle(AscendColor.textSecondary)
            }
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    GoalsHomeView()
        .environment(AppContainer.preview())
        .modelContainer(AppContainer.preview().modelContainer)
}
