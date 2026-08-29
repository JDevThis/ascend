import SwiftUI

struct ProfileHomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(AppContainer.self) private var container
    @State private var viewModel: ProfileViewModel?

    var body: some View {
        NavigationStack {
            Group {
                if let viewModel {
                    List {
                        Section {
                            HStack(spacing: AscendSpacing.md) {
                                Image(systemName: "person.crop.circle.fill")
                                    .font(.system(size: 48))
                                    .foregroundStyle(AscendColor.accent)
                                VStack(alignment: .leading) {
                                    TextField("Name", text: Binding(
                                        get: { viewModel.settings.displayName },
                                        set: { viewModel.settings.displayName = $0; viewModel.save() }
                                    ))
                                    .font(AscendFont.headline())
                                    Text("Ascend member")
                                        .font(AscendFont.footnote())
                                        .foregroundStyle(AscendColor.textSecondary)
                                }
                            }
                            .padding(.vertical, 4)
                        }

                        Section("Body & Progress") {
                            NavigationLink {
                                BodyMetricsView(viewModel: viewModel)
                            } label: {
                                Label("Body Metrics", systemImage: "chart.line.uptrend.xyaxis")
                            }
                            NavigationLink {
                                ProgressPhotosView(viewModel: viewModel)
                            } label: {
                                Label("Progress Photos", systemImage: "photo.on.rectangle.angled")
                            }
                        }

                        Section("Settings") {
                            NavigationLink {
                                PreferencesView(viewModel: viewModel)
                            } label: {
                                Label("Preferences", systemImage: "gearshape.fill")
                            }
                            NavigationLink {
                                HealthKitSettingsView(viewModel: viewModel)
                            } label: {
                                Label("Health Integration", systemImage: "heart.fill")
                            }
                            NavigationLink {
                                NotificationSettingsView(viewModel: viewModel)
                            } label: {
                                Label("Notifications", systemImage: "bell.fill")
                            }
                            NavigationLink {
                                DataExportView(viewModel: viewModel)
                            } label: {
                                Label("Data & Privacy", systemImage: "lock.shield.fill")
                            }
                        }

                        Section("About") {
                            HStack {
                                Text("Version")
                                Spacer()
                                Text(Bundle.main.appVersionString)
                                    .foregroundStyle(AscendColor.textSecondary)
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                } else {
                    ProgressView()
                }
            }
            .navigationTitle("Profile")
            .onAppear {
                if viewModel == nil {
                    viewModel = ProfileViewModel(
                        context: modelContext,
                        healthKitService: container.healthKitService,
                        notificationService: container.notificationService
                    )
                } else {
                    viewModel?.refresh()
                }
            }
        }
    }
}

extension Bundle {
    var appVersionString: String {
        let version = infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }
}

#Preview {
    ProfileHomeView()
        .environment(AppContainer.preview())
        .modelContainer(AppContainer.preview().modelContainer)
}
