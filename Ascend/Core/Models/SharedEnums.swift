import Foundation

enum HabitCategory: String, Codable, CaseIterable, Identifiable {
    case fitness = "Fitness"
    case health = "Health"
    case productivity = "Productivity"
    case learning = "Learning"
    case mindfulness = "Mindfulness"
    case custom = "Custom"

    var id: String { rawValue }

    var symbolName: String {
        switch self {
        case .fitness: return "figure.run"
        case .health: return "heart.fill"
        case .productivity: return "checkmark.circle.fill"
        case .learning: return "book.fill"
        case .mindfulness: return "leaf.fill"
        case .custom: return "star.fill"
        }
    }
}

enum GoalCategory: String, Codable, CaseIterable, Identifiable {
    case fitness = "Fitness"
    case health = "Health"
    case career = "Career"
    case financial = "Financial"
    case personal = "Personal"
    case learning = "Learning"
    case custom = "Custom"

    var id: String { rawValue }

    var symbolName: String {
        switch self {
        case .fitness: return "figure.strengthtraining.traditional"
        case .health: return "heart.text.square.fill"
        case .career: return "briefcase.fill"
        case .financial: return "dollarsign.circle.fill"
        case .personal: return "person.fill"
        case .learning: return "graduationcap.fill"
        case .custom: return "target"
        }
    }
}

enum GoalStatus: String, Codable, CaseIterable, Identifiable {
    case notStarted = "Not Started"
    case inProgress = "In Progress"
    case completed = "Completed"
    case abandoned = "Abandoned"

    var id: String { rawValue }
}

enum MuscleGroup: String, Codable, CaseIterable, Identifiable {
    case chest = "Chest"
    case back = "Back"
    case shoulders = "Shoulders"
    case biceps = "Biceps"
    case triceps = "Triceps"
    case legs = "Legs"
    case glutes = "Glutes"
    case core = "Core"
    case fullBody = "Full Body"
    case cardio = "Cardio"
    case other = "Other"

    var id: String { rawValue }
}

enum PhotoAngle: String, Codable, CaseIterable, Identifiable {
    case front = "Front"
    case side = "Side"
    case back = "Back"

    var id: String { rawValue }
}

enum MeasurementUnitSystem: String, Codable, CaseIterable, Identifiable {
    case imperial = "Imperial"
    case metric = "Metric"

    var id: String { rawValue }

    var weightUnitLabel: String { self == .imperial ? "lb" : "kg" }
    var distanceUnitLabel: String { self == .imperial ? "in" : "cm" }
}
