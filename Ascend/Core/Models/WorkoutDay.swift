import Foundation
import SwiftData

@Model
final class WorkoutDay {
    var id: UUID = UUID()
    var name: String = ""
    var order: Int = 0

    var program: WorkoutProgram?

    @Relationship(deleteRule: .cascade, inverse: \WorkoutDayExercise.day)
    var dayExercises: [WorkoutDayExercise]?

    @Relationship(deleteRule: .nullify, inverse: \WorkoutSession.plannedDay)
    var sessions: [WorkoutSession]?

    init(name: String, order: Int) {
        self.id = UUID()
        self.name = name
        self.order = order
        self.dayExercises = []
        self.sessions = []
    }

    var sortedExercises: [WorkoutDayExercise] {
        (dayExercises ?? []).sorted { $0.order < $1.order }
    }
}

/// Join entity linking a library Exercise to a WorkoutDay with planned sets/reps.
@Model
final class WorkoutDayExercise {
    var id: UUID = UUID()
    var order: Int = 0
    var targetSets: Int = 3
    var targetReps: Int = 10

    var exercise: Exercise?
    var day: WorkoutDay?

    init(exercise: Exercise?, order: Int, targetSets: Int = 3, targetReps: Int = 10) {
        self.id = UUID()
        self.exercise = exercise
        self.order = order
        self.targetSets = targetSets
        self.targetReps = targetReps
    }
}
