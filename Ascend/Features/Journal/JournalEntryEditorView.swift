import SwiftUI

struct JournalEntryEditorView: View {
    let viewModel: JournalViewModel
    let entry: JournalEntry?
    @Environment(\.dismiss) private var dismiss

    @State private var date: Date
    @State private var title: String
    @State private var body: String
    @State private var mood: Int
    @State private var tagsText: String
    @State private var showingPrompts = false

    init(viewModel: JournalViewModel, entry: JournalEntry?) {
        self.viewModel = viewModel
        self.entry = entry
        _date = State(initialValue: entry?.date ?? .now)
        _title = State(initialValue: entry?.title ?? "")
        _body = State(initialValue: entry?.body ?? "")
        _mood = State(initialValue: entry?.mood ?? 3)
        _tagsText = State(initialValue: entry?.tags.joined(separator: ", ") ?? "")
    }

    private var contentBody: some View {
        Form {
            Section("Date") {
                DatePicker("Date", selection: $date, displayedComponents: .date)
            }

            Section("Mood") {
                Picker("Mood", selection: $mood) {
                    Text("😞").tag(1)
                    Text("😕").tag(2)
                    Text("😐").tag(3)
                    Text("🙂").tag(4)
                    Text("😄").tag(5)
                }
                .pickerStyle(.segmented)
            }

            Section("Entry") {
                TextField("Title (optional)", text: $title)
                TextEditor(text: $body)
                    .frame(minHeight: 160)
                Button("Need a prompt?") { showingPrompts = true }
                    .font(AscendFont.footnote())
            }

            Section("Tags") {
                TextField("Comma separated (e.g. gym, work)", text: $tagsText)
            }

            if entry != nil {
                Section {
                    Button("Delete Entry", role: .destructive) {
                        if let entry {
                            viewModel.delete(entry)
                        }
                        dismiss()
                    }
                }
            }
        }
        .navigationTitle(entry == nil ? "New Entry" : "Edit Entry")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    let tags = tagsText
                        .split(separator: ",")
                        .map { $0.trimmingCharacters(in: .whitespaces) }
                        .filter { !$0.isEmpty }
                    if let entry {
                        viewModel.updateEntry(entry, title: title, body: body, mood: mood, tags: tags)
                    } else {
                        viewModel.createEntry(date: date, title: title, body: body, mood: mood, tags: tags)
                    }
                    dismiss()
                }
            }
        }
        .confirmationDialog("Guided Prompts", isPresented: $showingPrompts, titleVisibility: .visible) {
            ForEach(JournalViewModel.guidedPrompts, id: \.self) { prompt in
                Button(prompt) {
                    if body.isEmpty {
                        body = prompt + "\n\n"
                    } else {
                        body += "\n\n" + prompt + "\n\n"
                    }
                }
            }
        }
    }

    var body: some View {
        NavigationStack {
            contentBody
        }
    }
}
