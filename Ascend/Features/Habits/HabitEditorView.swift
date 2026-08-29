import SwiftUI

struct HabitEditorView: View {
    let viewModel: HabitsViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var category: HabitCategory = .fitness
    @State private var icon = "star.fill"
    @State private var colorHex = AscendColor.habitPalette[0]
    @State private var targetFrequency = 7
    @State private var reminderEnabled = false
    @State private var reminderTime = Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: .now) ?? .now

    private let iconOptions = [
        "star.fill", "drop.fill", "figure.walk", "book.fill", "brain.head.profile",
        "bed.double.fill", "leaf.fill", "pencil", "cup.and.saucer.fill", "sun.max.fill"
    ]

    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Name", text: $name)
                    Picker("Category", selection: $category) {
                        ForEach(HabitCategory.allCases) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                }

                Section("Icon") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5)) {
                        ForEach(iconOptions, id: \.self) { option in
                            Button {
                                icon = option
                            } label: {
                                Image(systemName: option)
                                    .font(.system(size: 20))
                                    .frame(width: 44, height: 44)
                                    .background(icon == option ? AscendColor.fromHex(colorHex).opacity(0.25) : AscendColor.surfaceSecondary, in: Circle())
                                    .foregroundStyle(icon == option ? AscendColor.fromHex(colorHex) : AscendColor.textSecondary)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                Section("Color") {
                    HStack {
                        ForEach(AscendColor.habitPalette, id: \.self) { hex in
                            Button {
                                colorHex = hex
                            } label: {
                                Circle()
                                    .fill(AscendColor.fromHex(hex))
                                    .frame(width: 32, height: 32)
                                    .overlay {
                                        if colorHex == hex {
                                            Circle().stroke(AscendColor.textPrimary, lineWidth: 2)
                                        }
                                    }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                Section("Frequency") {
                    Stepper("Target: \(targetFrequency)x per week", value: $targetFrequency, in: 1...7)
                }

                Section("Reminders") {
                    Toggle("Daily Reminder", isOn: $reminderEnabled)
                    if reminderEnabled {
                        DatePicker("Time", selection: $reminderTime, displayedComponents: .hourAndMinute)
                    }
                }
            }
            .navigationTitle("New Habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.createHabit(
                            name: name,
                            icon: icon,
                            colorHex: colorHex,
                            category: category,
                            targetFrequency: targetFrequency,
                            reminderEnabled: reminderEnabled,
                            reminderTime: reminderEnabled ? reminderTime : nil
                        )
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}
