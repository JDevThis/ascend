import Foundation
import SwiftData

@Model
final class WorkoutProgram {
    var id: UUID = UUID()
    var name: String = ""
    var programDescription: String = ""
    var createdAt: Date = Date.now
    var isActive: Bool = true

    @Relationship(deleteRule: .cascade, inverse: \WorkoutDay.program)
    var days: [WorkoutDay]?

    init(name: String, programDescription: String = "", isActive: Bool = true) {
        self.id = UUID()
        self.name = name
        self.programDescription = programDescription
        self.createdAt = .now
        self.isActive = isActive
        self.days = []
    }

    var sortedDays: [WorkoutDay] {
        (days ?? []).sorted { $0.order < $1.order }
    }
}
