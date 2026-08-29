import Foundation

/// Abstraction over HealthKit so ViewModels and tests never touch HKHealthStore directly.
protocol HealthKitServicing: Sendable {
    var isHealthDataAvailable: Bool { get }
    func requestAuthorization() async throws
    func mostRecentBodyMass() async throws -> Double? // pounds
    func mostRecentBodyFatPercentage() async throws -> Double?
    func saveBodyMass(pounds: Double, date: Date) async throws
    func saveWorkout(start: Date, end: Date, activeEnergyBurned: Double?) async throws -> UUID?
    func recentStepsToday() async throws -> Double?
}

struct NoopHealthKitService: HealthKitServicing {
    var isHealthDataAvailable: Bool { false }
    func requestAuthorization() async throws {}
    func mostRecentBodyMass() async throws -> Double? { nil }
    func mostRecentBodyFatPercentage() async throws -> Double? { nil }
    func saveBodyMass(pounds: Double, date: Date) async throws {}
    func saveWorkout(start: Date, end: Date, activeEnergyBurned: Double?) async throws -> UUID? { nil }
    func recentStepsToday() async throws -> Double? { nil }
}
