import Foundation
import UserNotifications

final class NotificationService: NotificationServicing, @unchecked Sendable {
    private let center = UNUserNotificationCenter.current()

    func requestAuthorization() async throws -> Bool {
        try await center.requestAuthorization(options: [.alert, .sound, .badge])
    }

    func scheduleHabitReminder(habitID: UUID, name: String, time: Date) async {
        let content = UNMutableNotificationContent()
        content.title = "Habit reminder"
        content.body = "Time for: \(name)"
        content.sound = .default

        var components = Calendar.current.dateComponents([.hour, .minute], from: time)
        components.hour = components.hour
        components.minute = components.minute
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)

        let request = UNNotificationRequest(identifier: identifier(prefix: "habit", id: habitID), content: content, trigger: trigger)
        try? await center.add(request)
    }

    func cancelHabitReminder(habitID: UUID) async {
        center.removePendingNotificationRequests(withIdentifiers: [identifier(prefix: "habit", id: habitID)])
    }

    func scheduleWorkoutReminder(dayID: UUID, name: String, weekday: Int, time: Date) async {
        let content = UNMutableNotificationContent()
        content.title = "Workout day"
        content.body = "\(name) is scheduled for today"
        content.sound = .default

        var components = Calendar.current.dateComponents([.hour, .minute], from: time)
        components.weekday = weekday
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)

        let request = UNNotificationRequest(identifier: identifier(prefix: "workout", id: dayID), content: content, trigger: trigger)
        try? await center.add(request)
    }

    func cancelWorkoutReminder(dayID: UUID) async {
        center.removePendingNotificationRequests(withIdentifiers: [identifier(prefix: "workout", id: dayID)])
    }

    func scheduleJournalPrompt(time: Date) async {
        let content = UNMutableNotificationContent()
        content.title = "Journal"
        content.body = "What went well today? Take a minute to reflect."
        content.sound = .default

        let components = Calendar.current.dateComponents([.hour, .minute], from: time)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)

        let request = UNNotificationRequest(identifier: "journal-prompt", content: content, trigger: trigger)
        try? await center.add(request)
    }

    func cancelJournalPrompt() async {
        center.removePendingNotificationRequests(withIdentifiers: ["journal-prompt"])
    }

    func scheduleRestTimerAlert(seconds: TimeInterval) async {
        let content = UNMutableNotificationContent()
        content.title = "Rest complete"
        content.body = "Time for your next set."
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: max(1, seconds), repeats: false)
        let request = UNNotificationRequest(identifier: "rest-timer-\(UUID().uuidString)", content: content, trigger: trigger)
        try? await center.add(request)
    }

    private func identifier(prefix: String, id: UUID) -> String {
        "\(prefix)-\(id.uuidString)"
    }
}
