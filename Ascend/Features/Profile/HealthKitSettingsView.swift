import SwiftUI

struct HealthKitSettingsView: View {
    let viewModel: ProfileViewModel

    var body: some View {
        Form {
            Section {
                Toggle("Sync with Apple Health", isOn: Binding(
                    get: { viewModel.settings.healthKitSyncEnabled },
                    set: { enabled in
                        if enabled {
                            Task { await viewModel.requestHealthKitAuthorization() }
                        } else {
                            viewModel.disableHealthKitSync()
                        }
                    }
                ))
            } footer: {
                Text("When enabled, Ascend reads your recent weight from Health to prefill body metric logging, and writes completed workouts and logged weight back to Health.")
            }

            if let error = viewModel.healthKitErrorMessage {
                Section {
                    Text(error)
                        .foregroundStyle(AscendColor.danger)
                }
            }

            Section("What Syncs") {
                Label("Body Weight", systemImage: "scalemass.fill")
                Label("Completed Workouts", systemImage: "figure.strengthtraining.traditional")
            }
        }
        .navigationTitle("Health Integration")
    }
}
