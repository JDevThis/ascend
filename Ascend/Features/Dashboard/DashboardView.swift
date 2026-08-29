import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(AppContainer.self) private var container
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: DashboardViewModel?

    var body: some View {
        NavigationStack {
            ScrollView {
                if let viewModel {
                    VStack(alignment: .leading, spacing: AscendSpacing.md) {
                        header(viewModel: viewModel)
                        ScoreStreakWidget(viewModel: viewModel)
                        TodaysHabitsWidget(viewModel: viewModel)
                        TodaysWorkoutWidget(viewModel: viewModel)
                        WeightTrendWidget(viewModel: viewModel)
                        GoalsProgressWidget(viewModel: viewModel)
                        WeeklyActivityWidget(viewModel: viewModel)
                    }
                    .padding(AscendSpacing.md)
                } else {
                    ProgressView()
                        .padding(.top, AscendSpacing.xxl)
                }
            }
            .background(AscendColor.background)
            .navigationTitle("Ascend")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                if viewModel == nil {
                    viewModel = DashboardViewModel(context: modelContext)
                } else {
                    viewModel?.refresh()
                }
            }
        }
    }

    @ViewBuilder
    private func header(viewModel: DashboardViewModel) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("\(viewModel.greeting), \(viewModel.displayName)")
                .font(AscendFont.largeTitle())
                .foregroundStyle(AscendColor.textPrimary)
            Text(viewModel.todayFormatted)
                .font(AscendFont.subheadline())
                .foregroundStyle(AscendColor.textSecondary)
        }
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    DashboardView()
        .environment(AppContainer.preview())
        .modelContainer(AppContainer.preview().modelContainer)
}
