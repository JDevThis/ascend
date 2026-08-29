import SwiftUI

struct RootTabView: View {
    var body: some View {
        TabView {
            Tab("Dashboard", systemImage: "house.fill") {
                DashboardView()
            }
            Tab("Workouts", systemImage: "dumbbell.fill") {
                WorkoutsHomeView()
            }
            Tab("Habits", systemImage: "checkmark.circle.fill") {
                HabitsHomeView()
            }
            Tab("Goals", systemImage: "target") {
                GoalsHomeView()
            }
            Tab("Journal", systemImage: "book.closed.fill") {
                JournalHomeView()
            }
            Tab("Profile", systemImage: "person.crop.circle.fill") {
                ProfileHomeView()
            }
        }
        .tint(AscendColor.accent)
    }
}

#Preview {
    RootTabView()
        .environment(AppContainer.preview())
        .modelContainer(AppContainer.preview().modelContainer)
}
