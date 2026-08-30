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
    /// HealthKit/Notification services. Falls back to a local-only store when
    /// CloudKit isn't usable — not signed into iCloud, iCloud disabled for this
    /// app, or (in an unsigned build, e.g. CI simulator runs) no iCloud entitlement
    /// at all.
    ///
    /// This has to be checked *before* attempting the CloudKit configuration, not
    /// via a do/catch around it: when the process genuinely lacks the iCloud
    /// entitlement, CKContainer aborts the process outright rather than throwing a
    /// catchable Swift error, so `try?` around ModelContainer(...) can't save us.
    /// `FileManager.ubiquityIdentityToken` is safe to call unconditionally — it
    /// just returns nil rather than crashing when iCloud isn't available.
    static func live() -> AppContainer {
        let healthKitService = HealthKitService()
        let notificationService = NotificationService()

        if FileManager.default.ubiquityIdentityToken != nil {
            let cloudConfiguration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false,
                cloudKitDatabase: .private("iCloud.com.ascend.app")
            )
            if let container = try? ModelContainer(for: schema, configurations: [cloudConfiguration]) {
                return AppContainer(
                    modelContainer: container,
                    healthKitService: healthKitService,
                    notificationService: notificationService
                )
            }
        }

        Logger(subsystem: "com.ascend.app", category: "Persistence")
            .warning("iCloud unavailable; falling back to local-only storage.")

        let localConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        guard let localContainer = try? ModelContainer(for: schema, configurations: [localConfiguration]) else {
            fatalError("Failed to create SwiftData ModelContainer, even without CloudKit")
        }

        return AppContainer(
            modelContainer: localContainer,
            healthKitService: healthKitService,
            notificationService: notificationService
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
