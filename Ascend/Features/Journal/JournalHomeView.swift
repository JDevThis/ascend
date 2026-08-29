import SwiftUI
import Charts

struct JournalHomeView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: JournalViewModel?
    @State private var isPresentingNewEntry = false

    var body: some View {
        NavigationStack {
            Group {
                if let viewModel {
                    List {
                        Section {
                            HStack {
                                StatTile(title: "Journal Streak", value: "\(viewModel.journalingStreak)", systemImage: "flame.fill", tint: AscendColor.warning)
                                StatTile(title: "Entries", value: "\(viewModel.entries.count)", systemImage: "book.fill", tint: AscendColor.accentSecondary)
                            }
                            .listRowInsets(EdgeInsets())
                            .padding(.vertical, 4)

                            if !viewModel.moodTrend.isEmpty {
                                Chart(viewModel.moodTrend) { point in
                                    LineMark(
                                        x: .value("Date", point.date),
                                        y: .value("Mood", point.mood)
                                    )
                                    .foregroundStyle(AscendColor.accent)
                                    .interpolationMethod(.catmullRom)
                                }
                                .frame(height: 100)
                                .chartYScale(domain: 1...5)
                                .chartXAxis(.hidden)
                                .padding(.vertical, 4)
                            }
                        } header: {
                            Text("Mood Trend")
                        }

                        if !viewModel.mostUsedTags.isEmpty {
                            Section("Most Used Tags") {
                                ForEach(viewModel.mostUsedTags.prefix(5)) { entry in
                                    HStack {
                                        Text(entry.tag)
                                        Spacer()
                                        Text("\(entry.count)")
                                            .foregroundStyle(AscendColor.textSecondary)
                                    }
                                }
                            }
                        }

                        if !viewModel.allTags.isEmpty {
                            Section("Filter by Tag") {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack {
                                        TagChip(title: "All", isSelected: viewModel.selectedTag == nil) {
                                            viewModel.selectedTag = nil
                                        }
                                        ForEach(viewModel.allTags, id: \.self) { tag in
                                            TagChip(title: tag, isSelected: viewModel.selectedTag == tag) {
                                                viewModel.selectedTag = tag
                                            }
                                        }
                                    }
                                }
                                .listRowInsets(EdgeInsets())
                            }
                        }

                        Section("Entries") {
                            if viewModel.filteredEntries.isEmpty {
                                Text("No entries yet. Tap + to write your first one.")
                                    .foregroundStyle(AscendColor.textSecondary)
                            } else {
                                ForEach(viewModel.filteredEntries) { entry in
                                    NavigationLink {
                                        JournalEntryEditorView(viewModel: viewModel, entry: entry)
                                    } label: {
                                        JournalEntryRow(entry: entry)
                                    }
                                }
                                .onDelete { indexSet in
                                    for index in indexSet {
                                        viewModel.delete(viewModel.filteredEntries[index])
                                    }
                                }
                            }
                        }
                    }
                    .searchable(text: Binding(get: { viewModel.searchText }, set: { viewModel.searchText = $0 }), prompt: "Search entries")
                } else {
                    ProgressView()
                }
            }
            .navigationTitle("Journal")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isPresentingNewEntry = true
                    } label: {
                        Image(systemName: "square.and.pencil")
                    }
                }
            }
            .sheet(isPresented: $isPresentingNewEntry) {
                if let viewModel {
                    JournalEntryEditorView(viewModel: viewModel, entry: nil)
                }
            }
            .onAppear {
                if viewModel == nil {
                    viewModel = JournalViewModel(context: modelContext)
                } else {
                    viewModel?.refresh()
                }
            }
        }
    }
}

private struct JournalEntryRow: View {
    let entry: JournalEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(moodEmoji(entry.mood))
                Text(entry.title.isEmpty ? entry.date.formatted(date: .abbreviated, time: .omitted) : entry.title)
                    .font(AscendFont.body())
                Spacer()
                Text(entry.date.formatted(date: .abbreviated, time: .omitted))
                    .font(AscendFont.footnote())
                    .foregroundStyle(AscendColor.textSecondary)
            }
            if !entry.body.isEmpty {
                Text(entry.body)
                    .font(AscendFont.footnote())
                    .foregroundStyle(AscendColor.textSecondary)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 2)
    }

    private func moodEmoji(_ mood: Int) -> String {
        switch mood {
        case 1: return "😞"
        case 2: return "😕"
        case 3: return "😐"
        case 4: return "🙂"
        default: return "😄"
        }
    }
}

private struct TagChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(AscendFont.footnote())
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? AscendColor.accent : AscendColor.surfaceSecondary, in: Capsule())
                .foregroundStyle(isSelected ? .white : AscendColor.textPrimary)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    JournalHomeView()
        .environment(AppContainer.preview())
        .modelContainer(AppContainer.preview().modelContainer)
}
