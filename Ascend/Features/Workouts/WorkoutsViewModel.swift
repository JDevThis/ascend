import Foundation
import SwiftData
import Observation

struct PersonalRecord: Identifiable {
    let id: PersistentIdentifier
    let exercise: Exercise
    let estimatedOneRepMax: Double
    let date: Date
}

@MainActor
@Observable
final class WorkoutsViewModel {
    private let context: ModelContext

    var programs: [WorkoutProgram] = []
    var exercises: [Exercise] = []
    var recentSessions: [WorkoutSession] = []

    init(context: ModelContext) {
        self.context = context
        refresh()
    }

    func refresh() {
        let programDescriptor = FetchDescriptor<WorkoutProgram>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
        programs = (try? context.fetch(programDescriptor)) ?? []

        let exerciseDescriptor = FetchDescriptor<Exercise>(sortBy: [SortDescriptor(\.name)])
        exercises = (try? context.fetch(exerciseDescriptor)) ?? []

        var sessionDescriptor = FetchDescriptor<WorkoutSession>(sortBy: [SortDescriptor(\.date, order: .reverse)])
        sessionDescriptor.fetchLimit = 100
        recentSessions = (try? context.fetch(sessionDescriptor)) ?? []
    }

    func createProgram(name: String, description: String) {
        for program in programs { program.isActive = false }
        let program = WorkoutProgram(name: name, programDescription: description, isActive: true)
        context.insert(program)
        try? context.save()
        refresh()
    }

    func setActive(_ program: WorkoutProgram) {
        for p in programs { p.isActive = (p.id == program.id) }
        try? context.save()
        refresh()
    }

    func deleteProgram(_ program: WorkoutProgram) {
        context.delete(program)
        try? context.save()
        refresh()
    }

    func createExercise(name: String, muscleGroup: MuscleGroup, notes: String) {
        let exercise = Exercise(name: name, muscleGroup: muscleGroup, notes: notes)
        context.insert(exercise)
        try? context.save()
        refresh()
    }

    func deleteExercise(_ exercise: Exercise) {
        context.delete(exercise)
        try? context.save()
        refresh()
    }

    // MARK: - Analytics

    func weeklyVolume(weeksBack: Int = 0) -> Double {
        let calendar = Calendar.current
        guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: calendar.date(byAdding: .weekOfYear, value: -weeksBack, to: .now) ?? .now) else { return 0 }
        return recentSessions
            .filter { weekInterval.contains($0.date) }
            .reduce(0) { $0 + $1.totalVolume }
    }

    func monthlyVolume(monthsBack: Int = 0) -> Double {
        let calendar = Calendar.current
        guard let monthInterval = calendar.dateInterval(of: .month, for: calendar.date(byAdding: .month, value: -monthsBack, to: .now) ?? .now) else { return 0 }
        return recentSessions
            .filter { monthInterval.contains($0.date) }
            .reduce(0) { $0 + $1.totalVolume }
    }

    /// Best estimated 1RM (Epley formula) per exercise across all logged sets.
    func personalRecords() -> [PersonalRecord] {
        var best: [PersistentIdentifier: PersonalRecord] = [:]
        for session in recentSessions {
            for set in (session.sets ?? []) where set.completed && set.weight > 0 && set.reps > 0 {
                guard let exercise = set.exercise else { continue }
                let oneRM = set.weight * (1 + Double(set.reps) / 30.0)
                if let current = best[exercise.persistentModelID], current.estimatedOneRepMax >= oneRM {
                    continue
                }
                best[exercise.persistentModelID] = PersonalRecord(
                    id: exercise.persistentModelID,
                    exercise: exercise,
                    estimatedOneRepMax: oneRM,
                    date: session.date
                )
            }
        }
        return best.values.sorted { $0.estimatedOneRepMax > $1.estimatedOneRepMax }
    }

    /// Consistency score: fraction of the last N weeks with at least one logged session.
    func consistencyScore(weeks: Int = 8) -> Double {
        let calendar = Calendar.current
        var activeWeeks = 0
        for offset in 0..<weeks {
            guard let interval = calendar.dateInterval(of: .weekOfYear, for: calendar.date(byAdding: .weekOfYear, value: -offset, to: .now) ?? .now) else { continue }
            if recentSessions.contains(where: { interval.contains($0.date) }) {
                activeWeeks += 1
            }
        }
        return weeks > 0 ? Double(activeWeeks) / Double(weeks) : 0
    }

    func history(for exercise: Exercise) -> [ExerciseSet] {
        (exercise.sets ?? []).filter(\.completed).sorted { ($0.session?.date ?? .distantPast) > ($1.session?.date ?? .distantPast) }
    }
}
