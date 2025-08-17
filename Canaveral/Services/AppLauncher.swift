import Foundation
import AppKit

class AppLauncher: ObservableObject {
    
    func launchApplication(_ app: Application) {
        // Avoid App Management permission by using system command
        let appPath = app.path
        
        DispatchQueue.global(qos: .background).async {
            let task = Process()
            task.launchPath = "/usr/bin/open"
            task.arguments = [appPath]
            try? task.run()
            task.waitUntilExit()
        }
        
        // Quit the app after launching (clean state management)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            NSApplication.shared.terminate(nil)
        }
    }
    
    func launchFirstFilteredApp(from apps: [Application], selectedIndex: Int) {
        if !apps.isEmpty && selectedIndex < apps.count {
            let appToLaunch = apps[selectedIndex]
            launchApplication(appToLaunch)
        }
    }
}
