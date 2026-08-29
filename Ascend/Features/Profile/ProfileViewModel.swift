import Foundation
import SwiftData
import Observation

@MainActor
@Observable
final class ProfileViewModel {
    private let context: ModelContext
    private let healthKitService: HealthKitServicing
    private let notificationService: NotificationServicing

    var settings: AppSettings
    var bodyMetrics: [BodyMetricEntry] = []
    var progressPhotos: [ProgressPhoto] = []
    var healthKitAuthorized = false
    var healthKitErrorMessage: String?

    init(context: ModelContext, healthKitService: HealthKitServicing, notificationService: NotificationServicing) {
        self.context = context
        self.healthKitService = healthKitService
        self.notificationService = notificationService

        let descriptor = FetchDescriptor<AppSettings>()
        if let existing = (try? context.fetch(descriptor))?.first {
            self.settings = existing
        } else {
            let newSettings = AppSettings()
            context.insert(newSettings)
            try? context.save()
            self.settings = newSettings
        }
        refresh()
    }

    func refresh() {
        let metricsDescriptor = FetchDescriptor<BodyMetricEntry>(sortBy: [SortDescriptor(\.date, order: .reverse)])
        bodyMetrics = (try? context.fetch(metricsDescriptor)) ?? []

        let photosDescriptor = FetchDescriptor<ProgressPhoto>(sortBy: [SortDescriptor(\.date, order: .reverse)])
        progressPhotos = (try? context.fetch(photosDescriptor)) ?? []
    }

    func save() {
        try? context.save()
    }

    // MARK: - Body Metrics

    func logWeight(pounds: Double, date: Date = .now) {
        let entry = BodyMetricEntry(date: date, weightLb: pounds)
        context.insert(entry)
        try? context.save()
        refresh()

        if settings.healthKitSyncEnabled {
            Task { try? await healthKitService.saveBodyMass(pounds: pounds, date: date) }
        }
    }

    func logMeasurements(
        date: Date = .now,
        weightLb: Double?,
        bodyFat: Double?,
        chest: Double?,
        waist: Double?,
        hips: Double?,
        arms: Double?,
        legs: Double?
    ) {
        let entry = BodyMetricEntry(
            date: date,
            weightLb: weightLb,
            bodyFatPercentage: bodyFat,
            chestIn: chest,
            waistIn: waist,
            hipsIn: hips,
            armsIn: arms,
            legsIn: legs
        )
        context.insert(entry)
        try? context.save()
        refresh()
    }

    func deleteMetric(_ entry: BodyMetricEntry) {
        context.delete(entry)
        try? context.save()
        refresh()
    }

    // MARK: - Progress Photos

    func addPhoto(angle: PhotoAngle, imageData: Data, date: Date = .now) {
        let photo = ProgressPhoto(date: date, angle: angle, imageData: imageData)
        context.insert(photo)
        try? context.save()
        refresh()
    }

    func deletePhoto(_ photo: ProgressPhoto) {
        context.delete(photo)
        try? context.save()
        refresh()
    }

    func photos(for angle: PhotoAngle) -> [ProgressPhoto] {
        progressPhotos.filter { $0.angle == angle }
    }

    // MARK: - HealthKit

    func requestHealthKitAuthorization() async {
        guard healthKitService.isHealthDataAvailable else {
            healthKitErrorMessage = "Health data isn't available on this device."
            return
        }
        do {
            try await healthKitService.requestAuthorization()
            healthKitAuthorized = true
            settings.healthKitSyncEnabled = true
            try? context.save()
        } catch {
            healthKitErrorMessage = error.localizedDescription
        }
    }

    func disableHealthKitSync() {
        settings.healthKitSyncEnabled = false
        try? context.save()
    }

    // MARK: - Notifications

    func requestNotificationAuthorization() async -> Bool {
        (try? await notificationService.requestAuthorization()) ?? false
    }

    func updateJournalPrompt(enabled: Bool, time: Date) {
        settings.journalPromptsEnabled = enabled
        try? context.save()
        Task {
            if enabled {
                await notificationService.scheduleJournalPrompt(time: time)
            } else {
                await notificationService.cancelJournalPrompt()
            }
        }
    }

    // MARK: - Data Export

    func exportDataAsJSON() -> Data? {
        struct ExportPayload: Encodable {
            let exportedAt: Date
            let displayName: String
            let bodyMetrics: [ExportedMetric]
            let goals: [ExportedGoal]
        }
        struct ExportedMetric: Encodable {
            let date: Date
            let weightLb: Double?
            let bodyFatPercentage: Double?
        }
        struct ExportedGoal: Encodable {
            let title: String
            let currentValue: Double
            let targetValue: Double
            let unit: String
        }

        let goalsDescriptor = FetchDescriptor<Goal>()
        let goals = (try? context.fetch(goalsDescriptor)) ?? []

        let payload = ExportPayload(
            exportedAt: .now,
            displayName: settings.displayName,
            bodyMetrics: bodyMetrics.map { ExportedMetric(date: $0.date, weightLb: $0.weightLb, bodyFatPercentage: $0.bodyFatPercentage) },
            goals: goals.map { ExportedGoal(title: $0.title, currentValue: $0.currentValue, targetValue: $0.targetValue, unit: $0.unit) }
        )

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return try? encoder.encode(payload)
    }

    func deleteAllData() {
        for photo in progressPhotos { context.delete(photo) }
        for metric in bodyMetrics { context.delete(metric) }

        let goalsDescriptor = FetchDescriptor<Goal>()
        for goal in (try? context.fetch(goalsDescriptor)) ?? [] { context.delete(goal) }

        let habitsDescriptor = FetchDescriptor<Habit>()
        for habit in (try? context.fetch(habitsDescriptor)) ?? [] { context.delete(habit) }

        let journalDescriptor = FetchDescriptor<JournalEntry>()
        for entry in (try? context.fetch(journalDescriptor)) ?? [] { context.delete(entry) }

        let programDescriptor = FetchDescriptor<WorkoutProgram>()
        for program in (try? context.fetch(programDescriptor)) ?? [] { context.delete(program) }

        try? context.save()
        refresh()
    }
}
