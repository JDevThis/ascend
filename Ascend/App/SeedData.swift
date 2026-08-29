import Foundation
import SwiftData

/// Populates a handful of default exercises, one starter habit set, and an example
/// goal on first launch so the app isn't empty out of the box. Idempotent — checks
/// for existing AppSettings before seeding.
@MainActor
enum SeedData {
    static func seedIfNeeded(context: ModelContext) {
        let settingsDescriptor = FetchDescriptor<AppSettings>()
        let existingSettings = (try? context.fetch(settingsDescriptor)) ?? []
        guard existingSettings.isEmpty else { return }

        context.insert(AppSettings())

        let defaultExercises: [(String, MuscleGroup)] = [
            ("Barbell Back Squat", .legs),
            ("Bench Press", .chest),
            ("Deadlift", .back),
            ("Overhead Press", .shoulders),
            ("Pull-Up", .back),
            ("Barbell Row", .back),
            ("Plank", .core),
            ("Running", .cardio)
        ]
        for (name, group) in defaultExercises {
            context.insert(Exercise(name: name, muscleGroup: group, isCustom: false))
        }

        let starterHabits: [(String, String, String, HabitCategory, Int)] = [
            ("Drink Water", "drop.fill", AscendColor.habitPalette[0], .health, 7),
            ("Move Daily", "figure.walk", AscendColor.habitPalette[1], .fitness, 7),
            ("Read", "book.fill", AscendColor.habitPalette[2], .learning, 5),
            ("Meditate", "brain.head.profile", AscendColor.habitPalette[3], .mindfulness, 7)
        ]
        for (name, icon, color, category, frequency) in starterHabits {
            context.insert(Habit(name: name, iconSymbolName: icon, colorHex: color, category: category, targetFrequency: frequency))
        }

        let starterGoal = Goal(
            title: "Bench Press 225 lb",
            goalDescription: "Build up to a 225 lb bench press for reps.",
            category: .fitness,
            targetValue: 225,
            currentValue: 135,
            unit: "lb",
            targetDate: Calendar.current.date(byAdding: .month, value: 6, to: .now) ?? .now
        )
        context.insert(starterGoal)

        try? context.save()
    }
}
