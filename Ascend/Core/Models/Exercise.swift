import Foundation
import SwiftData

@Model
final class Exercise {
    // CloudKit requires every non-optional attribute to carry an inline default
    // value (an init-assigned value alone doesn't satisfy schema validation).
    var id: UUID = UUID()
    var name: String = ""
    var muscleGroupRaw: String = MuscleGroup.other.rawValue
    var notes: String = ""
    var createdAt: Date = Date.now
    var isCustom: Bool = true

    @Relationship(deleteRule: .cascade, inverse: \WorkoutDayExercise.exercise)
    var dayAssignments: [WorkoutDayExercise]?

    /// Nullify rather than cascade: deleting a custom exercise from the library
    /// should not destroy previously logged workout history for it.
    @Relationship(deleteRule: .nullify, inverse: \ExerciseSet.exercise)
    var sets: [ExerciseSet]?

    var muscleGroup: MuscleGroup {
        get { MuscleGroup(rawValue: muscleGroupRaw) ?? .other }
        set { muscleGroupRaw = newValue.rawValue }
    }

    init(name: String, muscleGroup: MuscleGroup, notes: String = "", isCustom: Bool = true) {
        self.id = UUID()
        self.name = name
        self.muscleGroupRaw = muscleGroup.rawValue
        self.notes = notes
        self.createdAt = .now
        self.isCustom = isCustom
        self.dayAssignments = []
        self.sets = []
    }
}
