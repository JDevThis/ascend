import Foundation
import SwiftData
import SwiftUI

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

    /// Production container: real CloudKit-backed SwiftData store, real HealthKit/Notification services.
    static func live() -> AppContainer {
        let schema = Schema([
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

        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .private("iCloud.com.ascend.app")
        )

        let container: ModelContainer
        do {
            container = try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Failed to create SwiftData ModelContainer: \(error)")
        }

        return AppContainer(
            modelContainer: container,
            healthKitService: HealthKitService(),
            notificationService: NotificationService()
        )
    }

    /// In-memory container for previews and unit tests — no CloudKit, no HealthKit, no notifications.
    static func preview() -> AppContainer {
        let schema = Schema([
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
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: schema, configurations: [configuration])
        return AppContainer(
            modelContainer: container,
            healthKitService: NoopHealthKitService(),
            notificationService: NoopNotificationService()
        )
    }
}
