import Testing
@testable import Ascend

struct ScoringServiceTests {
    @Test func fullCompletionScoresOneHundred() {
        let score = ScoringService.dailyScore(
            habitsCompletedToday: 3,
            habitsTotalToday: 3,
            workoutCompletedToday: true,
            workoutScheduledToday: true,
            journaledToday: true
        )
        #expect(score == 100)
    }

    @Test func noActivityScoresZero() {
        let score = ScoringService.dailyScore(
            habitsCompletedToday: 0,
            habitsTotalToday: 3,
            workoutCompletedToday: false,
            workoutScheduledToday: true,
            journaledToday: false
        )
        #expect(score == 0)
    }

    @Test func noHabitsOrWorkoutScheduledStillCountsJournaling() {
        let score = ScoringService.dailyScore(
            habitsCompletedToday: 0,
            habitsTotalToday: 0,
            workoutCompletedToday: false,
            workoutScheduledToday: false,
            journaledToday: true
        )
        #expect(score == 100)
    }

    @Test func weeklyConsistencyCountsActiveDays() {
        let consistency = ScoringService.weeklyConsistency(dailyScores: [80, 20, 60, 0, 90, 50, 10])
        #expect(consistency == 4.0 / 7.0)
    }
}
