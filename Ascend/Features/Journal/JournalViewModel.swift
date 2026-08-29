import Foundation
import SwiftData
import Observation

struct MoodPoint: Identifiable {
    let id = UUID()
    let date: Date
    let mood: Int
}

struct TagCount: Identifiable {
    var id: String { tag }
    let tag: String
    let count: Int
}

@MainActor
@Observable
final class JournalViewModel {
    private let context: ModelContext

    var entries: [JournalEntry] = []
    var searchText: String = ""
    var selectedTag: String?

    init(context: ModelContext) {
        self.context = context
        refresh()
    }

    func refresh() {
        let descriptor = FetchDescriptor<JournalEntry>(sortBy: [SortDescriptor(\.date, order: .reverse)])
        entries = (try? context.fetch(descriptor)) ?? []
    }

    var filteredEntries: [JournalEntry] {
        entries.filter { entry in
            let matchesSearch = searchText.isEmpty
                || entry.title.localizedCaseInsensitiveContains(searchText)
                || entry.body.localizedCaseInsensitiveContains(searchText)
            let matchesTag = selectedTag == nil || entry.tags.contains(selectedTag!)
            return matchesSearch && matchesTag
        }
    }

    var allTags: [String] {
        Array(Set(entries.flatMap(\.tags))).sorted()
    }

    func createEntry(date: Date, title: String, body: String, mood: Int, tags: [String]) {
        let entry = JournalEntry(date: date, title: title, body: body, mood: mood, tags: tags)
        context.insert(entry)
        try? context.save()
        refresh()
    }

    func updateEntry(_ entry: JournalEntry, title: String, body: String, mood: Int, tags: [String]) {
        entry.title = title
        entry.body = body
        entry.mood = mood
        entry.tags = tags
        entry.updatedAt = .now
        try? context.save()
        refresh()
    }

    func delete(_ entry: JournalEntry) {
        context.delete(entry)
        try? context.save()
        refresh()
    }

    func hasEntry(on date: Date, calendar: Calendar = .current) -> Bool {
        entries.contains { calendar.isDate($0.date, inSameDayAs: date) }
    }

    /// Consecutive days ending today with a journal entry.
    var journalingStreak: Int {
        let calendar = Calendar.current
        var streak = 0
        var cursor = calendar.startOfDay(for: .now)
        if !hasEntry(on: cursor) {
            cursor = calendar.date(byAdding: .day, value: -1, to: cursor) ?? cursor
        }
        while hasEntry(on: cursor) {
            streak += 1
            guard let prev = calendar.date(byAdding: .day, value: -1, to: cursor) else { break }
            cursor = prev
        }
        return streak
    }

    var moodTrend: [MoodPoint] {
        entries.sorted { $0.date < $1.date }.suffix(30).map { MoodPoint(date: $0.date, mood: $0.mood) }
    }

    var mostUsedTags: [TagCount] {
        var counts: [String: Int] = [:]
        for entry in entries {
            for tag in entry.tags {
                counts[tag, default: 0] += 1
            }
        }
        return counts.sorted { $0.value > $1.value }.map { TagCount(tag: $0.key, count: $0.value) }
    }

    static let guidedPrompts = [
        "What went well today?",
        "What's one thing you're grateful for?",
        "What challenged you today, and how did you respond?",
        "What's one small win from today?",
        "What do you want to focus on tomorrow?"
    ]
}
