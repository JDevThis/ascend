import SwiftUI

struct NotificationSettingsView: View {
    let viewModel: ProfileViewModel
    @State private var journalPromptTime = Calendar.current.date(bySettingHour: 20, minute: 0, second: 0, of: .now) ?? .now
    @State private var permissionDenied = false

    var body: some View {
        Form {
            Section("Habit Reminders") {
                Text("Manage individual habit reminder times from each habit's detail screen in the Habits tab.")
                    .font(AscendFont.footnote())
                    .foregroundStyle(AscendColor.textSecondary)
            }

            Section("Workout Reminders") {
                Toggle("Workout Day Reminders", isOn: Binding(
                    get: { viewModel.settings.workoutRemindersEnabled },
                    set: { viewModel.settings.workoutRemindersEnabled = $0; viewModel.save() }
                ))
            }

            Section("Journal") {
                Toggle("Daily Journal Prompt", isOn: Binding(
                    get: { viewModel.settings.journalPromptsEnabled },
                    set: { viewModel.updateJournalPrompt(enabled: $0, time: journalPromptTime) }
                ))
                if viewModel.settings.journalPromptsEnabled {
                    DatePicker("Time", selection: $journalPromptTime, displayedComponents: .hourAndMinute)
                        .onChange(of: journalPromptTime) { _, newValue in
                            viewModel.updateJournalPrompt(enabled: true, time: newValue)
                        }
                }
            }
        }
        .navigationTitle("Notifications")
        .task {
            let granted = await viewModel.requestNotificationAuthorization()
            permissionDenied = !granted
        }
        .alert("Notifications Disabled", isPresented: $permissionDenied) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Enable notifications for Ascend in Settings to receive reminders.")
        }
    }
}
