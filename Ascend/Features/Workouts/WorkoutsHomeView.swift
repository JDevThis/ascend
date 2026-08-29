import SwiftUI

struct WorkoutsHomeView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: WorkoutsViewModel?
    @State private var isPresentingNewProgram = false

    var body: some View {
        NavigationStack {
            Group {
                if let viewModel {
                    List {
                        Section {
                            NavigationLink {
                                ExerciseLibraryView(viewModel: viewModel)
                            } label: {
                                Label("Exercise Library", systemImage: "list.bullet.rectangle.fill")
                            }
                            NavigationLink {
                                WorkoutHistoryView(viewModel: viewModel)
                            } label: {
                                Label("Workout History", systemImage: "clock.arrow.circlepath")
                            }
                            NavigationLink {
                                WorkoutAnalyticsView(viewModel: viewModel)
                            } label: {
                                Label("Analytics", systemImage: "chart.xyaxis.line")
                            }
                        }

                        Section("Programs") {
                            if viewModel.programs.isEmpty {
                                Text("No programs yet. Tap + to create one.")
                                    .foregroundStyle(AscendColor.textSecondary)
                            } else {
                                ForEach(viewModel.programs) { program in
                                    NavigationLink {
                                        ProgramDetailView(viewModel: viewModel, program: program)
                                    } label: {
                                        ProgramRow(program: program)
                                    }
                                }
                                .onDelete { indexSet in
                                    for index in indexSet {
                                        viewModel.deleteProgram(viewModel.programs[index])
                                    }
                                }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                } else {
                    ProgressView()
                }
            }
            .navigationTitle("Workouts")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isPresentingNewProgram = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $isPresentingNewProgram) {
                if let viewModel {
                    ProgramEditorView(viewModel: viewModel)
                }
            }
            .onAppear {
                if viewModel == nil {
                    viewModel = WorkoutsViewModel(context: modelContext)
                } else {
                    viewModel?.refresh()
                }
            }
        }
    }
}

private struct ProgramRow: View {
    let program: WorkoutProgram

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(program.name)
                        .font(AscendFont.body())
                    if program.isActive {
                        Text("ACTIVE")
                            .font(.system(size: 10, weight: .bold))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(AscendColor.accent.opacity(0.2), in: Capsule())
                            .foregroundStyle(AscendColor.accent)
                    }
                }
                Text("\(program.sortedDays.count) days")
                    .font(AscendFont.footnote())
                    .foregroundStyle(AscendColor.textSecondary)
            }
            Spacer()
        }
    }
}

#Preview {
    WorkoutsHomeView()
        .environment(AppContainer.preview())
        .modelContainer(AppContainer.preview().modelContainer)
}
