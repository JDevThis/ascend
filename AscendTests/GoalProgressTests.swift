import Foundation
import Testing
@testable import Ascend

struct GoalProgressTests {
    @Test func progressClampsBetweenZeroAndOne() {
        let goal = Goal(title: "Test", category: .fitness, targetValue: 100, currentValue: 150, unit: "lb", targetDate: .now)
        #expect(goal.progress == 1.0)
    }

    @Test func progressComputesFraction() {
        let goal = Goal(title: "Test", category: .fitness, targetValue: 200, currentValue: 50, unit: "lb", targetDate: .now)
        #expect(goal.progress == 0.25)
    }

    @Test func overdueDetectsPastTargetDateWhenNotCompleted() {
        let pastDate = Calendar.current.date(byAdding: .day, value: -1, to: .now) ?? .now
        let goal = Goal(title: "Test", category: .fitness, targetValue: 100, currentValue: 10, unit: "lb", targetDate: pastDate)
        #expect(goal.isOverdue)
    }

    @Test func completedGoalsAreNeverOverdue() {
        let pastDate = Calendar.current.date(byAdding: .day, value: -1, to: .now) ?? .now
        let goal = Goal(title: "Test", category: .fitness, targetValue: 100, currentValue: 100, unit: "lb", targetDate: pastDate)
        goal.status = .completed
        #expect(!goal.isOverdue)
    }
}
