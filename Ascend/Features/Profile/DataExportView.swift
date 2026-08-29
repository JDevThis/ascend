import SwiftUI

struct DataExportView: View {
    let viewModel: ProfileViewModel
    @State private var exportURL: URL?
    @State private var isPresentingDeleteConfirmation = false

    var body: some View {
        Form {
            Section {
                Button("Export My Data") {
                    exportURL = writeExportFile()
                }
                if let exportURL {
                    ShareLink(item: exportURL) {
                        Label("Share Export", systemImage: "square.and.arrow.up")
                    }
                }
            } footer: {
                Text("Exports body metrics and goals as a JSON file you own and can keep outside Ascend.")
            }

            Section("iCloud Sync") {
                Label("Synced via your private iCloud database", systemImage: "icloud.fill")
                    .foregroundStyle(AscendColor.textSecondary)
            }

            Section {
                Button("Delete All Data", role: .destructive) {
                    isPresentingDeleteConfirmation = true
                }
            } footer: {
                Text("Permanently deletes all habits, goals, workouts, journal entries, and photos from this device and iCloud.")
            }
        }
        .navigationTitle("Data & Privacy")
        .confirmationDialog(
            "Delete all data? This cannot be undone.",
            isPresented: $isPresentingDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete Everything", role: .destructive) {
                viewModel.deleteAllData()
            }
            Button("Cancel", role: .cancel) {}
        }
    }

    private func writeExportFile() -> URL? {
        guard let data = viewModel.exportDataAsJSON() else { return nil }
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("ascend-export-\(Date.now.timeIntervalSince1970).json")
        try? data.write(to: url)
        return url
    }
}
