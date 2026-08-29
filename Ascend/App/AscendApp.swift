import SwiftUI
import SwiftData

@main
struct AscendApp: App {
    @State private var container = AppContainer.live()

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environment(container)
                .modelContainer(container.modelContainer)
                .task {
                    SeedData.seedIfNeeded(context: container.modelContainer.mainContext)
                }
        }
    }
}
