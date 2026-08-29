import Foundation
import SwiftData
import Observation

@MainActor
@Observable
final class GoalsViewModel {
    private let context: ModelContext

    var goals: [Goal] = []

    init(context: ModelContext) {
        self.context = context
        refresh()
    }

    func refresh() {
        let descriptor = FetchDescriptor<Goal>(sortBy: [SortDescriptor(\.targetDate)])
        goals = (try? context.fetch(descriptor)) ?? []
    }

    var activeGoals: [Goal] {
        goals.filter { $0.status != .completed && $0.status != .abandoned }
    }

    var archivedGoals: [Goal] {
        goals.filter { $0.status == .completed || $0.status == .abandoned }
    }

    func createGoal(
        title: String,
        description: String,
        category: GoalCategory,
        targetValue: Double,
        currentValue: Double,
        unit: String,
        targetDate: Date
    ) {
        let goal = Goal(
            title: title,
            goalDescription: description,
            category: category,
            targetValue: targetValue,
            currentValue: currentValue,
            unit: unit,
            targetDate: targetDate
        )
        goal.status = currentValue > 0 ? .inProgress : .notStarted
        context.insert(goal)
        try? context.save()
        refresh()
    }

    func updateProgress(_ goal: Goal, currentValue: Double) {
        goal.currentValue = currentValue
        if goal.status == .notStarted, currentValue > 0 {
            goal.status = .inProgress
        }
        if goal.progress >= 1.0 {
            goal.status = .completed
            for milestone in (goal.milestones ?? []) where milestone.completionDate == nil && milestone.targetValue <= currentValue {
                milestone.completionDate = .now
            }
        } else {
            for milestone in (goal.milestones ?? []) where milestone.completionDate == nil && milestone.targetValue <= currentValue {
                milestone.completionDate = .now
            }
        }
        try? context.save()
    }

    func addMilestone(to goal: Goal, title: String, targetValue: Double) {
        let milestone = Milestone(title: title, targetValue: targetValue)
        milestone.goal = goal
        goal.milestones?.append(milestone)
        context.insert(milestone)
        try? context.save()
    }

    func setStatus(_ goal: Goal, status: GoalStatus) {
        goal.status = status
        try? context.save()
        refresh()
    }

    func delete(_ goal: Goal) {
        context.delete(goal)
        try? context.save()
        refresh()
    }

    var completionRate: Double {
        guard !goals.isEmpty else { return 0 }
        return Double(goals.filter { $0.status == .completed }.count) / Double(goals.count)
    }

    var onTrackCount: Int {
        activeGoals.filter { !$0.isOverdue }.count
    }

    var behindScheduleCount: Int {
        activeGoals.filter(\.isOverdue).count
    }
}
