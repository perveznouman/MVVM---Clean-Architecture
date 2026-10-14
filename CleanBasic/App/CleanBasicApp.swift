import SwiftUI

/// ENTRY POINT: creates the container once and shows the tabs.
@main
struct CleanBasicApp: App {
    @State private var container = AppContainer()

    var body: some Scene {
        WindowGroup {
            RootView(container: container)
        }
    }
}
