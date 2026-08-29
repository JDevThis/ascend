import SwiftUI

struct GoalsProgressWidget: View {
    let viewModel: DashboardViewModel

    var body: some View {
        AscendCard {
            AscendCardHeader(title: "Goals Progress", systemImage: "target")

            if viewModel.activeGoals.isEmpty {
                Text("No active goals. Set one in the Goals tab.")
                    .font(AscendFont.footnote())
                    .foregroundStyle(AscendColor.textSecondary)
            } else {
                VStack(spacing: AscendSpacing.sm) {
                    ForEach(viewModel.activeGoals.prefix(3)) { goal in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(goal.title)
                                    .font(AscendFont.body())
                                    .foregroundStyle(AscendColor.textPrimary)
                                ProgressView(value: goal.progress)
                                    .tint(AscendColor.accentSecondary)
                            }
                            Spacer()
                            Text("\(Int(goal.progress * 100))%")
                                .font(AscendFont.footnote())
                                .foregroundStyle(AscendColor.textSecondary)
                        }
                    }
                }
            }
        }
    }
}
