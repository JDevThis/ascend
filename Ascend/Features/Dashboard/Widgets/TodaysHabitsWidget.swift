import SwiftUI

struct TodaysHabitsWidget: View {
    let viewModel: DashboardViewModel

    private var completedCount: Int {
        viewModel.habitsToday.filter { $0.isCompleted(on: .now) }.count
    }

    var body: some View {
        AscendCard {
            AscendCardHeader(title: "Today's Habits", systemImage: "checkmark.circle.fill")
            if viewModel.habitsToday.isEmpty {
                Text("No habits yet. Add one from the Habits tab.")
                    .font(AscendFont.footnote())
                    .foregroundStyle(AscendColor.textSecondary)
            } else {
                Text("\(completedCount) of \(viewModel.habitsToday.count) complete")
                    .font(AscendFont.subheadline())
                    .foregroundStyle(AscendColor.textSecondary)

                VStack(spacing: AscendSpacing.xs) {
                    ForEach(viewModel.habitsToday.prefix(5)) { habit in
                        HabitRow(habit: habit) {
                            viewModel.toggleHabit(habit)
                        }
                    }
                }
            }
        }
    }
}

private struct HabitRow: View {
    let habit: Habit
    let onToggle: () -> Void

    private var isDone: Bool { habit.isCompleted(on: .now) }

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: AscendSpacing.sm) {
                Image(systemName: habit.iconSymbolName)
                    .foregroundStyle(AscendColor.fromHex(habit.colorHex))
                    .frame(width: 24)
                Text(habit.name)
                    .font(AscendFont.body())
                    .foregroundStyle(AscendColor.textPrimary)
                Spacer()
                Image(systemName: isDone ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isDone ? AscendColor.success : AscendColor.textSecondary)
                    .font(.system(size: 20))
            }
            .padding(.vertical, AscendSpacing.xxs)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(habit.name), \(isDone ? "completed" : "not completed")")
        .accessibilityAddTraits(.isButton)
    }
}
