import Foundation
import Testing
@testable import Ascend

struct HabitStreakTests {
    private func makeHabit(completedDaysAgo daysAgo: [Int]) -> Habit {
        let habit = Habit(name: "Test", iconSymbolName: "star.fill", colorHex: "#6BD9A6", category: .fitness, targetFrequency: 7)
        let calendar = Calendar.current
        habit.completions = daysAgo.map { offset in
            let completion = HabitCompletion(date: calendar.date(byAdding: .day, value: -offset, to: .now) ?? .now)
            completion.habit = habit
            return completion
        }
        return habit
    }

    @Test func currentStreakCountsConsecutiveDaysEndingToday() {
        let habit = makeHabit(completedDaysAgo: [0, 1, 2])
        #expect(habit.currentStreak() == 3)
    }

    @Test func currentStreakToleratesMissingToday() {
        let habit = makeHabit(completedDaysAgo: [1, 2, 3])
        #expect(habit.currentStreak() == 3)
    }

    @Test func currentStreakBreaksOnGap() {
        let habit = makeHabit(completedDaysAgo: [0, 2, 3])
        #expect(habit.currentStreak() == 1)
    }

    @Test func longestStreakFindsBestRun() {
        let habit = makeHabit(completedDaysAgo: [0, 1, 5, 6, 7, 8])
        #expect(habit.longestStreak() == 4)
    }

    @Test func noCompletionsMeansZeroStreak() {
        let habit = makeHabit(completedDaysAgo: [])
        #expect(habit.currentStreak() == 0)
        #expect(habit.longestStreak() == 0)
    }
}
