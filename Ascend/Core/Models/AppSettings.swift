import Foundation
import SwiftData

/// Single-row model (there should only ever be one instance) for CloudKit-synced
/// preferences that need to follow the user across devices.
@Model
final class AppSettings {
    var id: UUID = UUID()
    var unitSystemRaw: String = MeasurementUnitSystem.imperial.rawValue
    var startOfWeekRaw: Int = 1 // 1 = Sunday ... 7 = Saturday, matches Calendar.firstWeekday
    var displayName: String = "Athlete"
    var healthKitSyncEnabled: Bool = false
    var habitRemindersEnabled: Bool = true
    var workoutRemindersEnabled: Bool = true
    var journalPromptsEnabled: Bool = false
    var quietHoursStart: Date?
    var quietHoursEnd: Date?

    var unitSystem: MeasurementUnitSystem {
        get { MeasurementUnitSystem(rawValue: unitSystemRaw) ?? .imperial }
        set { unitSystemRaw = newValue.rawValue }
    }

    init(
        displayName: String = "Athlete",
        unitSystem: MeasurementUnitSystem = .imperial,
        startOfWeek: Int = 1
    ) {
        self.id = UUID()
        self.displayName = displayName
        self.unitSystemRaw = unitSystem.rawValue
        self.startOfWeekRaw = startOfWeek
        self.healthKitSyncEnabled = false
        self.habitRemindersEnabled = true
        self.workoutRemindersEnabled = true
        self.journalPromptsEnabled = false
    }
}
