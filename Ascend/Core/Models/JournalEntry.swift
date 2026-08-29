import Foundation
import SwiftData

@Model
final class JournalEntry {
    var id: UUID = UUID()
    var date: Date = Date.now
    var title: String = ""
    var body: String = ""
    /// 1 (lowest) ... 5 (highest)
    var mood: Int = 3
    var tags: [String] = []
    var linkedWorkoutSessionID: UUID?
    var linkedHabitID: UUID?

    @Attribute(.externalStorage)
    var attachedPhotoData: Data?

    var createdAt: Date = Date.now
    var updatedAt: Date = Date.now

    init(
        date: Date = .now,
        title: String = "",
        body: String = "",
        mood: Int = 3,
        tags: [String] = []
    ) {
        self.id = UUID()
        self.date = date
        self.title = title
        self.body = body
        self.mood = mood
        self.tags = tags
        self.createdAt = .now
        self.updatedAt = .now
    }
}
