import Foundation
import AppKit
import SwiftUI

class WindowManager: ObservableObject {
    
    func makeFullScreen() {
        if let window = NSApplication.shared.windows.first {
            // Safe window setup to avoid system errors
            window.styleMask = [.borderless, .fullSizeContentView]
            window.titlebarAppearsTransparent = true
            window.titleVisibility = .hidden
            window.standardWindowButton(.closeButton)?.isHidden = true
            window.standardWindowButton(.miniaturizeButton)?.isHidden = true
            window.standardWindowButton(.zoomButton)?.isHidden = true
            
            // Set to full screen safely
            let screenFrame = NSScreen.main?.frame ?? window.frame
            window.setFrame(screenFrame, display: true)
            
            // Set window level for background app
            window.level = .screenSaver // Above dock and menu bar (technically not allowed)
            // window.level = .floating // Alt for better compatibility
            
            // Enable transparency
            window.isOpaque = false
            window.backgroundColor = NSColor.clear
            window.hasShadow = false
            
            // Activate as background app
            activateAsBackgroundApp()
            
            // Simple activation
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
        }
    }
    
    private func activateAsBackgroundApp() {
        // Activate the app without showing in dock
        NSApp.setActivationPolicy(.accessory)
        
        // Ensure proper background app behavior
        DispatchQueue.main.async {
            NSApp.activate(ignoringOtherApps: true)
        }
    }
    
    func showApp() {
        if let window = NSApplication.shared.windows.first {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
        }
    }
    
    func hideApp() {
        if let window = NSApplication.shared.windows.first {
            window.orderOut(nil)
        }
    }
    
    func setupWindowTransparency() {
        DispatchQueue.main.async {
            NSApp.windows.forEach { w in
                w.isOpaque = false
                w.backgroundColor = .clear
                w.titleVisibility = .hidden
                w.titlebarAppearsTransparent = true
            }
        }
    }
}
