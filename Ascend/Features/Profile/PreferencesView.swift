import SwiftUI

struct PreferencesView: View {
    let viewModel: ProfileViewModel

    var body: some View {
        Form {
            Section("Units") {
                Picker("Unit System", selection: Binding(
                    get: { viewModel.settings.unitSystem },
                    set: { viewModel.settings.unitSystem = $0; viewModel.save() }
                )) {
                    ForEach(MeasurementUnitSystem.allCases) { system in
                        Text(system.rawValue).tag(system)
                    }
                }
            }

            Section("Calendar") {
                Picker("Start of Week", selection: Binding(
                    get: { viewModel.settings.startOfWeekRaw },
                    set: { viewModel.settings.startOfWeekRaw = $0; viewModel.save() }
                )) {
                    Text("Sunday").tag(1)
                    Text("Monday").tag(2)
                }
            }

            Section {
                Text("Appearance follows your system's Light/Dark Mode setting under Settings > Display & Brightness.")
                    .font(AscendFont.footnote())
                    .foregroundStyle(AscendColor.textSecondary)
            } header: {
                Text("Appearance")
            }
        }
        .navigationTitle("Preferences")
    }
}
