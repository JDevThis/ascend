import Foundation
import SwiftData
import SwiftUI
import OSLog

/// Lightweight dependency-injection container. Concrete services are created once
/// at launch and handed down through the SwiftUI environment; ViewModels depend
/// only on the protocol types, so tests can substitute Noop/mock implementations.
@MainActor
@Observable
final class AppContainer {
    let modelContainer: ModelContainer
    let healthKitService: HealthKitServicing
    let notificationService: NotificationServicing

    init(
        modelContainer: ModelContainer,
        healthKitService: HealthKitServicing,
        notificationService: NotificationServicing
    ) {
        self.modelContainer = modelContainer
        self.healthKitService = healthKitService
        self.notificationService = notificationService
    }

    private static let schema = Schema([
        WorkoutProgram.self,
        WorkoutDay.self,
        WorkoutDayExercise.self,
        Exercise.self,
        WorkoutSession.self,
        ExerciseSet.self,
        Habit.self,
        HabitCompletion.self,
        Goal.self,
        Milestone.self,
        JournalEntry.self,
        BodyMetricEntry.self,
        ProgressPhoto.self,
        AppSettings.self
    ])

    /// Production container: CloudKit-backed SwiftData store when available, real
    /// HealthKit/Notification services. Falls back to a local-only store if the
    /// CloudKit-backed one can't be created — this isn't just a CI/unsigned-build
    /// concern, it also covers real users who aren't signed into iCloud or have it
    /// disabled for this app; the app should degrade gracefully, not crash.
    static func live() -> AppContainer {
        let cloudConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .private("iCloud.com.ascend.app")
        )

        if let container = try? ModelContainer(for: schema, configurations: [cloudConfiguration]) {
            return AppContainer(
                modelContainer: container,
                healthKitService: HealthKitService(),
                notificationService: NotificationService()
            )
        }

        Logger(subsystem: "com.ascend.app", category: "Persistence")
            .warning("CloudKit-backed ModelContainer unavailable; falling back to local-only storage.")

        let localConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        guard let localContainer = try? ModelContainer(for: schema, configurations: [localConfiguration]) else {
            fatalError("Failed to create SwiftData ModelContainer, even without CloudKit")
        }

        return AppContainer(
            modelContainer: localContainer,
            healthKitService: HealthKitService(),
            notificationService: NotificationService()
        )
    }

    /// In-memory container for previews and unit tests — no CloudKit, no HealthKit, no notifications.
    static func preview() -> AppContainer {
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: schema, configurations: [configuration])
        return AppContainer(
            modelContainer: container,
            healthKitService: NoopHealthKitService(),
            notificationService: NoopNotificationService()
        )
    }
}
