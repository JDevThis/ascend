import Foundation
import SwiftData

@Model
final class WorkoutSession {
    var id: UUID = UUID()
    var date: Date = Date.now
    var duration: TimeInterval = 0
    var notes: String = ""

    var plannedDay: WorkoutDay?

    @Relationship(deleteRule: .cascade, inverse: \ExerciseSet.session)
    var sets: [ExerciseSet]?

    /// Set when this session was mirrored to HealthKit as a workout.
    var healthKitWorkoutUUID: UUID?

    init(date: Date = .now, duration: TimeInterval = 0, notes: String = "", plannedDay: WorkoutDay? = nil) {
        self.id = UUID()
        self.date = date
        self.duration = duration
        self.notes = notes
        self.plannedDay = plannedDay
        self.sets = []
    }

    var totalVolume: Double {
        (sets ?? []).reduce(0) { $0 + ($1.weight * Double($1.reps)) }
    }

    var completedSets: [ExerciseSet] {
        (sets ?? []).filter(\.completed)
    }
}

@Model
final class ExerciseSet {
    var id: UUID = UUID()
    var order: Int = 0
    var reps: Int = 0
    var weight: Double = 0
    var rpe: Double?
    var completed: Bool = false

    var exercise: Exercise?
    var session: WorkoutSession?

    init(exercise: Exercise?, order: Int, reps: Int = 0, weight: Double = 0, rpe: Double? = nil, completed: Bool = false) {
        self.id = UUID()
        self.exercise = exercise
        self.order = order
        self.reps = reps
        self.weight = weight
        self.rpe = rpe
        self.completed = completed
    }
}
