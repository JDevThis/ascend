import Foundation
import SwiftData
import Observation

@MainActor
@Observable
final class DashboardViewModel {
    private let context: ModelContext
    private let calendar = Calendar.current

    var habitsToday: [Habit] = []
    var todaysSession: WorkoutSession?
    var nextPlannedDay: WorkoutDay?
    var activeProgram: WorkoutProgram?
    var recentWeightEntries: [BodyMetricEntry] = []
    var activeGoals: [Goal] = []
    var weeklyScores: [Int] = [] // oldest -> newest, 7 entries
    var dailyScore: Int = 0
    var currentStreak: Int = 0
    var displayName: String = "Athlete"

    init(context: ModelContext) {
        self.context = context
        refresh()
    }

    var greeting: String {
        let hour = calendar.component(.hour, from: .now)
        switch hour {
        case 5..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        case 17..<22: return "Good evening"
        default: return "Still going"
        }
    }

    var todayFormatted: String {
        Date.now.formatted(.dateTime.weekday(.wide).month(.wide).day())
    }

    func refresh() {
        loadSettings()
        loadHabits()
        loadWorkout()
        loadWeight()
        loadGoals()
        computeScores()
    }

    func toggleHabit(_ habit: Habit) {
        if let existing = (habit.completions ?? []).first(where: { calendar.isDate($0.date, inSameDayAs: .now) }) {
            context.delete(existing)
            habit.completions?.removeAll { $0.id == existing.id }
        } else {
            let completion = HabitCompletion(date: .now)
            completion.habit = habit
            habit.completions?.append(completion)
            context.insert(completion)
        }
        try? context.save()
        computeScores()
    }

    private func loadSettings() {
        let descriptor = FetchDescriptor<AppSettings>()
        displayName = (try? context.fetch(descriptor))?.first?.displayName ?? "Athlete"
    }

    private func loadHabits() {
        let descriptor = FetchDescriptor<Habit>(
            predicate: #Predicate { $0.isArchived == false },
            sortBy: [SortDescriptor(\.createdAt)]
        )
        habitsToday = (try? context.fetch(descriptor)) ?? []
    }

    private func loadWorkout() {
        let programDescriptor = FetchDescriptor<WorkoutProgram>(predicate: #Predicate { $0.isActive == true })
        activeProgram = (try? context.fetch(programDescriptor))?.first

        let sessionDescriptor = FetchDescriptor<WorkoutSession>(sortBy: [SortDescriptor(\.date, order: .reverse)])
        let sessions = (try? context.fetch(sessionDescriptor)) ?? []
        todaysSession = sessions.first { calendar.isDate($0.date, inSameDayAs: .now) }

        guard let program = activeProgram else {
            nextPlannedDay = nil
            return
        }
        let days = program.sortedDays
        guard !days.isEmpty else {
            nextPlannedDay = nil
            return
        }
        let completedCount = sessions.filter { session in days.contains { $0.id == session.plannedDay?.id } }.count
        nextPlannedDay = days[completedCount % days.count]
    }

    private func loadWeight() {
        var descriptor = FetchDescriptor<BodyMetricEntry>(sortBy: [SortDescriptor(\.date, order: .reverse)])
        descriptor.fetchLimit = 30
        recentWeightEntries = ((try? context.fetch(descriptor)) ?? []).reversed()
    }

    private func loadGoals() {
        let descriptor = FetchDescriptor<Goal>(
            predicate: #Predicate { $0.statusRaw != "Completed" && $0.statusRaw != "Abandoned" },
            sortBy: [SortDescriptor(\.targetDate)]
        )
        activeGoals = (try? context.fetch(descriptor)) ?? []
    }

    private func computeScores() {
        let habitsTotal = habitsToday.count
        let habitsCompleted = habitsToday.filter { $0.isCompleted(on: .now, calendar: calendar) }.count
        let journalDescriptor = FetchDescriptor<JournalEntry>()
        let journaledToday = ((try? context.fetch(journalDescriptor)) ?? []).contains { calendar.isDate($0.date, inSameDayAs: .now) }

        dailyScore = ScoringService.dailyScore(
            habitsCompletedToday: habitsCompleted,
            habitsTotalToday: habitsTotal,
            workoutCompletedToday: todaysSession != nil,
            workoutScheduledToday: activeProgram != nil,
            journaledToday: journaledToday
        )

        weeklyScores = (0..<7).reversed().map { offset in
            let day = calendar.date(byAdding: .day, value: -offset, to: .now) ?? .now
            let habitsCompletedThatDay = habitsToday.filter { $0.isCompleted(on: day, calendar: calendar) }.count
            let sessionThatDay = (try? context.fetch(FetchDescriptor<WorkoutSession>()))?.contains {
                calendar.isDate($0.date, inSameDayAs: day)
            } ?? false
            let journaledThatDay = ((try? context.fetch(journalDescriptor)) ?? []).contains {
                calendar.isDate($0.date, inSameDayAs: day)
            }
            return ScoringService.dailyScore(
                habitsCompletedToday: habitsCompletedThatDay,
                habitsTotalToday: habitsTotal,
                workoutCompletedToday: sessionThatDay,
                workoutScheduledToday: activeProgram != nil,
                journaledToday: journaledThatDay
            )
        }

        currentStreak = 0
        for score in weeklyScores.reversed() {
            if score >= 50 { currentStreak += 1 } else { break }
        }
    }
}
