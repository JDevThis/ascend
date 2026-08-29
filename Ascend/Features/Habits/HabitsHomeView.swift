import SwiftUI

struct HabitsHomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(AppContainer.self) private var container
    @State private var viewModel: HabitsViewModel?
    @State private var isPresentingNewHabit = false

    var body: some View {
        NavigationStack {
            Group {
                if let viewModel {
                    if viewModel.habits.isEmpty {
                        EmptyStateView(
                            systemImage: "checkmark.circle",
                            title: "No habits yet",
                            message: "Build consistency by tracking daily habits.",
                            actionTitle: "Add Habit"
                        ) {
                            isPresentingNewHabit = true
                        }
                    } else {
                        List {
                            ForEach(HabitCategory.allCases) { category in
                                let habitsInCategory = viewModel.habits.filter { $0.category == category }
                                if !habitsInCategory.isEmpty {
                                    Section(category.rawValue) {
                                        ForEach(habitsInCategory) { habit in
                                            NavigationLink {
                                                HabitDetailView(viewModel: viewModel, habit: habit)
                                            } label: {
                                                HabitSummaryRow(habit: habit) {
                                                    viewModel.toggleCompletion(habit)
                                                }
                                            }
                                        }
                                        .onDelete { indexSet in
                                            for index in indexSet {
                                                viewModel.delete(habitsInCategory[index])
                                            }
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
            .navigationTitle("Habits")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isPresentingNewHabit = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $isPresentingNewHabit) {
                if let viewModel {
                    HabitEditorView(viewModel: viewModel)
                }
            }
            .onAppear {
                if viewModel == nil {
                    viewModel = HabitsViewModel(context: modelContext, notificationService: container.notificationService)
                } else {
                    viewModel?.refresh()
                }
            }
        }
    }
}

private struct HabitSummaryRow: View {
    let habit: Habit
    let onToggle: () -> Void

    var body: some View {
        HStack(spacing: AscendSpacing.sm) {
            Image(systemName: habit.iconSymbolName)
                .foregroundStyle(AscendColor.fromHex(habit.colorHex))
                .frame(width: 28)
            VStack(alignment: .leading, spacing: 2) {
                Text(habit.name).font(AscendFont.body())
                Text("\(habit.currentStreak())-day streak · \(Int(habit.successRate() * 100))% success")
                    .font(AscendFont.footnote())
                    .foregroundStyle(AscendColor.textSecondary)
            }
            Spacer()
            Button(action: onToggle) {
                Image(systemName: habit.isCompleted(on: .now) ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(habit.isCompleted(on: .now) ? AscendColor.success : AscendColor.textSecondary)
                    .font(.system(size: 22))
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    HabitsHomeView()
        .environment(AppContainer.preview())
        .modelContainer(AppContainer.preview().modelContainer)
}
