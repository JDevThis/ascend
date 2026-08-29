import SwiftUI

struct GoalEditorView: View {
    let viewModel: GoalsViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var description = ""
    @State private var category: GoalCategory = .fitness
    @State private var targetValue = ""
    @State private var currentValue = ""
    @State private var unit = ""
    @State private var targetDate = Calendar.current.date(byAdding: .month, value: 3, to: .now) ?? .now

    var body: some View {
        NavigationStack {
            Form {
                Section("Goal") {
                    TextField("Title", text: $title)
                    TextField("Description", text: $description, axis: .vertical)
                    Picker("Category", selection: $category) {
                        ForEach(GoalCategory.allCases) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                }
                Section("Progress") {
                    TextField("Current Value", text: $currentValue)
                        .keyboardType(.decimalPad)
                    TextField("Target Value", text: $targetValue)
                        .keyboardType(.decimalPad)
                    TextField("Unit (e.g. lb, pages, $)", text: $unit)
                }
                Section("Timeline") {
                    DatePicker("Target Date", selection: $targetDate, displayedComponents: .date)
                }
            }
            .navigationTitle("New Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.createGoal(
                            title: title,
                            description: description,
                            category: category,
                            targetValue: Double(targetValue) ?? 0,
                            currentValue: Double(currentValue) ?? 0,
                            unit: unit,
                            targetDate: targetDate
                        )
                        dismiss()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty || Double(targetValue) == nil)
                }
            }
        }
    }
}
