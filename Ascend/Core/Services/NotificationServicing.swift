import Foundation

protocol NotificationServicing: Sendable {
    func requestAuthorization() async throws -> Bool
    func scheduleHabitReminder(habitID: UUID, name: String, time: Date) async
    func cancelHabitReminder(habitID: UUID) async
    func scheduleWorkoutReminder(dayID: UUID, name: String, weekday: Int, time: Date) async
    func cancelWorkoutReminder(dayID: UUID) async
    func scheduleJournalPrompt(time: Date) async
    func cancelJournalPrompt() async
    func scheduleRestTimerAlert(seconds: TimeInterval) async
}

struct NoopNotificationService: NotificationServicing {
    func requestAuthorization() async throws -> Bool { false }
    func scheduleHabitReminder(habitID: UUID, name: String, time: Date) async {}
    func cancelHabitReminder(habitID: UUID) async {}
    func scheduleWorkoutReminder(dayID: UUID, name: String, weekday: Int, time: Date) async {}
    func cancelWorkoutReminder(dayID: UUID) async {}
    func scheduleJournalPrompt(time: Date) async {}
    func cancelJournalPrompt() async {}
    func scheduleRestTimerAlert(seconds: TimeInterval) async {}
}
