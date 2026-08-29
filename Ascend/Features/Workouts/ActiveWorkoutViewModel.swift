import Foundation
import SwiftData
import Observation

@MainActor
@Observable
final class ActiveWorkoutViewModel {
    private let context: ModelContext
    private let notificationService: NotificationServicing
    private let healthKitService: HealthKitServicing

    let day: WorkoutDay?
    var session: WorkoutSession
    var elapsed: TimeInterval = 0
    var isRunning = false
    var restRemaining: TimeInterval = 0
    var isResting = false
    var syncToHealth = true

    private var workoutTimer: Timer?
    private var restTimer: Timer?
    private let startTime = Date.now

    init(
        context: ModelContext,
        day: WorkoutDay?,
        notificationService: NotificationServicing,
        healthKitService: HealthKitServicing
    ) {
        self.context = context
        self.day = day
        self.notificationService = notificationService
        self.healthKitService = healthKitService
        self.session = WorkoutSession(date: .now, plannedDay: day)

        if let day {
            for assignment in day.sortedExercises {
                for setIndex in 0..<assignment.targetSets {
                    let set = ExerciseSet(exercise: assignment.exercise, order: setIndex, reps: assignment.targetReps)
                    session.sets?.append(set)
                }
            }
        }
    }

    func start() {
        guard !isRunning else { return }
        isRunning = true
        workoutTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.elapsed += 1
            }
        }
    }

    func pause() {
        isRunning = false
        workoutTimer?.invalidate()
        workoutTimer = nil
    }

    func startRest(seconds: TimeInterval = 90) {
        isResting = true
        restRemaining = seconds
        restTimer?.invalidate()
        Task { await notificationService.scheduleRestTimerAlert(seconds: seconds) }
        restTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            Task { @MainActor in
                guard let self else { return }
                self.restRemaining -= 1
                if self.restRemaining <= 0 {
                    self.isResting = false
                    timer.invalidate()
                }
            }
        }
    }

    func skipRest() {
        restTimer?.invalidate()
        isResting = false
        restRemaining = 0
    }

    func toggleCompleted(_ set: ExerciseSet) {
        set.completed.toggle()
        if set.completed {
            startRest()
        }
        try? context.save()
    }

    func finish() async {
        pause()
        session.duration = elapsed
        context.insert(session)
        try? context.save()

        if syncToHealth {
            let end = startTime.addingTimeInterval(elapsed)
            let uuid = try? await healthKitService.saveWorkout(start: startTime, end: end, activeEnergyBurned: nil)
            session.healthKitWorkoutUUID = uuid.flatMap { $0 }
            try? context.save()
        }
    }

    func cancel() {
        pause()
        restTimer?.invalidate()
    }
}
