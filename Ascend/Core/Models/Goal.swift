import Foundation
import SwiftData

@Model
final class Goal {
    var id: UUID = UUID()
    var title: String = ""
    var goalDescription: String = ""
    var categoryRaw: String = GoalCategory.custom.rawValue
    var targetValue: Double = 0
    var currentValue: Double = 0
    var unit: String = ""
    var startDate: Date = Date.now
    var targetDate: Date = Date.now
    var statusRaw: String = GoalStatus.notStarted.rawValue
    var createdAt: Date = Date.now

    /// Optional link to a Habit whose completions auto-advance progress.
    var linkedHabitID: UUID?
    /// Optional link to an Exercise whose best set (est. 1RM) auto-advances progress.
    var linkedExerciseID: UUID?

    @Relationship(deleteRule: .cascade, inverse: \Milestone.goal)
    var milestones: [Milestone]?

    var category: GoalCategory {
        get { GoalCategory(rawValue: categoryRaw) ?? .custom }
        set { categoryRaw = newValue.rawValue }
    }

    var status: GoalStatus {
        get { GoalStatus(rawValue: statusRaw) ?? .notStarted }
        set { statusRaw = newValue.rawValue }
    }

    init(
        title: String,
        goalDescription: String = "",
        category: GoalCategory,
        targetValue: Double,
        currentValue: Double = 0,
        unit: String,
        startDate: Date = .now,
        targetDate: Date
    ) {
        self.id = UUID()
        self.title = title
        self.goalDescription = goalDescription
        self.categoryRaw = category.rawValue
        self.targetValue = targetValue
        self.currentValue = currentValue
        self.unit = unit
        self.startDate = startDate
        self.targetDate = targetDate
        self.statusRaw = GoalStatus.notStarted.rawValue
        self.createdAt = .now
        self.milestones = []
    }

    var progress: Double {
        guard targetValue != 0 else { return 0 }
        return min(1.0, max(0.0, currentValue / targetValue))
    }

    var isOverdue: Bool {
        status != .completed && status != .abandoned && targetDate < .now
    }

    var sortedMilestones: [Milestone] {
        (milestones ?? []).sorted { $0.targetValue < $1.targetValue }
    }
}

@Model
final class Milestone {
    var id: UUID = UUID()
    var title: String = ""
    var targetValue: Double = 0
    var completionDate: Date?

    var goal: Goal?

    init(title: String, targetValue: Double, completionDate: Date? = nil) {
        self.id = UUID()
        self.title = title
        self.targetValue = targetValue
        self.completionDate = completionDate
    }

    var isCompleted: Bool { completionDate != nil }
}
