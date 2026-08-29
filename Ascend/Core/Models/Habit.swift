import Foundation
import SwiftData

@Model
final class Habit {
    var id: UUID
    var name: String
    var iconSymbolName: String
    var colorHex: String
    var categoryRaw: String
    /// Target number of completions per week (1...7).
    var targetFrequency: Int
    var reminderEnabled: Bool
    var reminderTime: Date?
    var createdAt: Date
    var isArchived: Bool

    @Relationship(deleteRule: .cascade, inverse: \HabitCompletion.habit)
    var completions: [HabitCompletion]?

    var category: HabitCategory {
        get { HabitCategory(rawValue: categoryRaw) ?? .custom }
        set { categoryRaw = newValue.rawValue }
    }

    init(
        name: String,
        iconSymbolName: String,
        colorHex: String,
        category: HabitCategory,
        targetFrequency: Int = 7,
        reminderEnabled: Bool = false,
        reminderTime: Date? = nil
    ) {
        self.id = UUID()
        self.name = name
        self.iconSymbolName = iconSymbolName
        self.colorHex = colorHex
        self.categoryRaw = category.rawValue
        self.targetFrequency = targetFrequency
        self.reminderEnabled = reminderEnabled
        self.reminderTime = reminderTime
        self.createdAt = .now
        self.isArchived = false
        self.completions = []
    }

    func isCompleted(on date: Date, calendar: Calendar = .current) -> Bool {
        (completions ?? []).contains { calendar.isDate($0.date, inSameDayAs: date) }
    }

    /// Current consecutive-day streak ending today (or yesterday if today not yet done).
    func currentStreak(calendar: Calendar = .current) -> Int {
        let days = Set((completions ?? []).map { calendar.startOfDay(for: $0.date) })
        guard !days.isEmpty else { return 0 }
        var streak = 0
        var cursor = calendar.startOfDay(for: .now)
        if !days.contains(cursor) {
            cursor = calendar.date(byAdding: .day, value: -1, to: cursor) ?? cursor
        }
        while days.contains(cursor) {
            streak += 1
            guard let prev = calendar.date(byAdding: .day, value: -1, to: cursor) else { break }
            cursor = prev
        }
        return streak
    }

    func longestStreak(calendar: Calendar = .current) -> Int {
        let days = Set((completions ?? []).map { calendar.startOfDay(for: $0.date) }).sorted()
        guard !days.isEmpty else { return 0 }
        var longest = 1
        var current = 1
        for i in 1..<days.count {
            if let expected = calendar.date(byAdding: .day, value: 1, to: days[i - 1]), expected == days[i] {
                current += 1
                longest = max(longest, current)
            } else {
                current = 1
            }
        }
        return longest
    }

    func successRate(sinceDaysAgo days: Int = 30, calendar: Calendar = .current) -> Double {
        let start = calendar.date(byAdding: .day, value: -days, to: .now) ?? .now
        let expectedCompletions = Double(targetFrequency) * (Double(days) / 7.0)
        guard expectedCompletions > 0 else { return 0 }
        let actual = (completions ?? []).filter { $0.date >= start }.count
        return min(1.0, Double(actual) / expectedCompletions)
    }
}

@Model
final class HabitCompletion {
    var id: UUID
    var date: Date

    var habit: Habit?

    init(date: Date = .now) {
        self.id = UUID()
        self.date = date
    }
}
