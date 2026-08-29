import Foundation
import HealthKit

/// Real HealthKit-backed implementation. Only reachable on-device / real simulator
/// with HealthKit entitlement + Info.plist usage descriptions configured.
final class HealthKitService: HealthKitServicing, @unchecked Sendable {
    private let store = HKHealthStore()

    private let bodyMassType = HKQuantityType(.bodyMass)
    private let bodyFatType = HKQuantityType(.bodyFatPercentage)
    private let stepType = HKQuantityType(.stepCount)
    private let activeEnergyType = HKQuantityType(.activeEnergyBurned)
    private let workoutType = HKObjectType.workoutType()

    var isHealthDataAvailable: Bool { HKHealthStore.isHealthDataAvailable() }

    func requestAuthorization() async throws {
        guard isHealthDataAvailable else { return }
        let readTypes: Set<HKObjectType> = [bodyMassType, bodyFatType, stepType, activeEnergyType, workoutType]
        let writeTypes: Set<HKSampleType> = [bodyMassType, workoutType, activeEnergyType]
        try await store.requestAuthorization(toShare: writeTypes, read: readTypes)
    }

    func mostRecentBodyMass() async throws -> Double? {
        try await mostRecentQuantitySample(for: bodyMassType, unit: .pound())
    }

    func mostRecentBodyFatPercentage() async throws -> Double? {
        try await mostRecentQuantitySample(for: bodyFatType, unit: .percent())
    }

    func saveBodyMass(pounds: Double, date: Date) async throws {
        let quantity = HKQuantity(unit: .pound(), doubleValue: pounds)
        let sample = HKQuantitySample(type: bodyMassType, quantity: quantity, start: date, end: date)
        try await store.save(sample)
    }

    func saveWorkout(start: Date, end: Date, activeEnergyBurned: Double?) async throws -> UUID? {
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .traditionalStrengthTraining

        let builder = HKWorkoutBuilder(healthStore: store, configuration: configuration, device: .local())
        try await builder.beginCollection(at: start)

        if let energy = activeEnergyBurned {
            let quantity = HKQuantity(unit: .kilocalorie(), doubleValue: energy)
            let sample = HKQuantitySample(type: activeEnergyType, quantity: quantity, start: start, end: end)
            try await builder.addSamples([sample])
        }

        try await builder.endCollection(at: end)
        let workout = try await builder.finishWorkout()
        return workout?.uuid
    }

    func recentStepsToday() async throws -> Double? {
        let start = Calendar.current.startOfDay(for: .now)
        let predicate = HKQuery.predicateForSamples(withStart: start, end: .now)
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, stats, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                continuation.resume(returning: stats?.sumQuantity()?.doubleValue(for: .count()))
            }
            store.execute(query)
        }
    }

    private func mostRecentQuantitySample(for type: HKQuantityType, unit: HKUnit) async throws -> Double? {
        let sort = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(sampleType: type, predicate: nil, limit: 1, sortDescriptors: [sort]) { _, samples, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                let value = (samples?.first as? HKQuantitySample)?.quantity.doubleValue(for: unit)
                continuation.resume(returning: value)
            }
            store.execute(query)
        }
    }
}
