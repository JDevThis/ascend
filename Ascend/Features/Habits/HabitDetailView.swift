import SwiftUI

struct HabitDetailView: View {
    let viewModel: HabitsViewModel
    let habit: Habit
    @State private var displayedMonth = Date.now

    var body: some View {
        List {
            Section {
                HStack {
                    StatTile(title: "Current Streak", value: "\(habit.currentStreak())", systemImage: "flame.fill", tint: AscendColor.warning)
                    StatTile(title: "Longest Streak", value: "\(habit.longestStreak())", systemImage: "trophy.fill", tint: AscendColor.accentSecondary)
                }
                .listRowInsets(EdgeInsets())
                .padding(.vertical, 4)
                StatTile(title: "Success Rate (30 days)", value: "\(Int(habit.successRate() * 100))%", systemImage: "chart.bar.fill")
                    .listRowInsets(EdgeInsets())
                    .padding(.vertical, 4)
            }

            Section {
                MonthCalendarView(month: displayedMonth, habit: habit) { date in
                    viewModel.toggleCompletion(habit, on: date)
                }
                HStack {
                    Button {
                        displayedMonth = Calendar.current.date(byAdding: .month, value: -1, to: displayedMonth) ?? displayedMonth
                    } label: {
                        Image(systemName: "chevron.left")
                    }
                    Spacer()
                    Text(displayedMonth.formatted(.dateTime.month(.wide).year()))
                        .font(AscendFont.subheadline())
                    Spacer()
                    Button {
                        displayedMonth = Calendar.current.date(byAdding: .month, value: 1, to: displayedMonth) ?? displayedMonth
                    } label: {
                        Image(systemName: "chevron.right")
                    }
                }
            } header: {
                Text("Monthly Calendar")
            }

            Section("Reminders") {
                Toggle("Daily Reminder", isOn: Binding(
                    get: { habit.reminderEnabled },
                    set: { viewModel.updateReminder(for: habit, enabled: $0, time: habit.reminderTime ?? .now) }
                ))
                if habit.reminderEnabled {
                    DatePicker("Time", selection: Binding(
                        get: { habit.reminderTime ?? .now },
                        set: { viewModel.updateReminder(for: habit, enabled: true, time: $0) }
                    ), displayedComponents: .hourAndMinute)
                }
            }

            Section {
                Button("Archive Habit", role: .destructive) {
                    viewModel.archive(habit)
                }
            }
        }
        .navigationTitle(habit.name)
    }
}

private struct MonthCalendarView: View {
    let month: Date
    let habit: Habit
    let onToggle: (Date) -> Void

    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)

    private var daysInMonth: [Date?] {
        guard let range = calendar.range(of: .day, in: .month, for: month),
              let firstOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: month))
        else { return [] }

        let weekdayOfFirst = calendar.component(.weekday, from: firstOfMonth)
        let leadingBlanks = (weekdayOfFirst - calendar.firstWeekday + 7) % 7

        var days: [Date?] = Array(repeating: nil, count: leadingBlanks)
        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstOfMonth) {
                days.append(date)
            }
        }
        return days
    }

    var body: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(0..<daysInMonth.count, id: \.self) { index in
                if let date = daysInMonth[index] {
                    let isDone = habit.isCompleted(on: date, calendar: calendar)
                    let isFuture = date > .now
                    Button {
                        if !isFuture { onToggle(date) }
                    } label: {
                        Text("\(calendar.component(.day, from: date))")
                            .font(.system(size: 13, weight: .medium))
                            .frame(width: 32, height: 32)
                            .background(isDone ? AscendColor.fromHex(habit.colorHex) : AscendColor.surfaceSecondary, in: Circle())
                            .foregroundStyle(isDone ? .white : (isFuture ? AscendColor.textSecondary.opacity(0.4) : AscendColor.textSecondary))
                    }
                    .buttonStyle(.plain)
                    .disabled(isFuture)
                } else {
                    Color.clear.frame(width: 32, height: 32)
                }
            }
        }
        .padding(.vertical, 8)
    }
}
