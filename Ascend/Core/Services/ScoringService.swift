import Foundation

/// Pure, side-effect-free scoring logic shared by the Dashboard and analytics screens.
/// Kept as static functions on a plain type so it is trivially testable.
enum ScoringService {
    /// A 0...100 daily score blending habit completion, workout completion, and journaling.
    static func dailyScore(
        habitsCompletedToday: Int,
        habitsTotalToday: Int,
        workoutCompletedToday: Bool,
        workoutScheduledToday: Bool,
        journaledToday: Bool
    ) -> Int {
        var earned = 0.0
        var possible = 0.0

        if habitsTotalToday > 0 {
            earned += 60.0 * (Double(habitsCompletedToday) / Double(habitsTotalToday))
            possible += 60.0
        }

        if workoutScheduledToday {
            earned += workoutCompletedToday ? 30.0 : 0.0
            possible += 30.0
        }

        earned += journaledToday ? 10.0 : 0.0
        possible += 10.0

        guard possible > 0 else { return 0 }
        return Int((earned / possible * 100).rounded())
    }

    /// Fraction (0...1) of the last `days` days where at least one habit was completed
    /// and any scheduled workout was done, used for "Weekly Consistency".
    static func weeklyConsistency(dailyScores: [Int]) -> Double {
        guard !dailyScores.isEmpty else { return 0 }
        let activeDays = dailyScores.filter { $0 >= 50 }.count
        return Double(activeDays) / Double(dailyScores.count)
    }
}
