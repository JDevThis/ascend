import Foundation
import SwiftData
import Observation

@MainActor
@Observable
final class HabitsViewModel {
    private let context: ModelContext
    private let notificationService: NotificationServicing

    var habits: [Habit] = []

    init(context: ModelContext, notificationService: NotificationServicing) {
        self.context = context
        self.notificationService = notificationService
        refresh()
    }

    func refresh() {
        let descriptor = FetchDescriptor<Habit>(
            predicate: #Predicate { $0.isArchived == false },
            sortBy: [SortDescriptor(\.createdAt)]
        )
        habits = (try? context.fetch(descriptor)) ?? []
    }

    func createHabit(
        name: String,
        icon: String,
        colorHex: String,
        category: HabitCategory,
        targetFrequency: Int,
        reminderEnabled: Bool,
        reminderTime: Date?
    ) {
        let habit = Habit(
            name: name,
            iconSymbolName: icon,
            colorHex: colorHex,
            category: category,
            targetFrequency: targetFrequency,
            reminderEnabled: reminderEnabled,
            reminderTime: reminderTime
        )
        context.insert(habit)
        try? context.save()
        refresh()
        if reminderEnabled, let reminderTime {
            Task { await notificationService.scheduleHabitReminder(habitID: habit.id, name: habit.name, time: reminderTime) }
        }
    }

    func updateReminder(for habit: Habit, enabled: Bool, time: Date?) {
        habit.reminderEnabled = enabled
        habit.reminderTime = time
        try? context.save()
        Task {
            if enabled, let time {
                await notificationService.scheduleHabitReminder(habitID: habit.id, name: habit.name, time: time)
            } else {
                await notificationService.cancelHabitReminder(habitID: habit.id)
            }
        }
    }

    func toggleCompletion(_ habit: Habit, on date: Date = .now) {
        let calendar = Calendar.current
        if let existing = (habit.completions ?? []).first(where: { calendar.isDate($0.date, inSameDayAs: date) }) {
            context.delete(existing)
            habit.completions?.removeAll { $0.id == existing.id }
        } else {
            let completion = HabitCompletion(date: date)
            completion.habit = habit
            habit.completions?.append(completion)
            context.insert(completion)
        }
        try? context.save()
    }

    func archive(_ habit: Habit) {
        habit.isArchived = true
        try? context.save()
        Task { await notificationService.cancelHabitReminder(habitID: habit.id) }
        refresh()
    }

    func delete(_ habit: Habit) {
        Task { await notificationService.cancelHabitReminder(habitID: habit.id) }
        context.delete(habit)
        try? context.save()
        refresh()
    }
}
