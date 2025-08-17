import SwiftUI

@available(macOS 14.0, *)
@main
struct AppLauncherApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .defaultSize(width: NSScreen.main?.frame.width ?? 1200, height: NSScreen.main?.frame.height ?? 800)
    }
}
