import SwiftUI
import AppKit

struct LaunchpadBackdrop: View {
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.colorScheme) private var scheme
    @State private var wallpaper: NSImage? = WallpaperProvider.currentScreenWallpaper()

    var body: some View {
        ZStack {
            if let wp = wallpaper {
                Image(nsImage: wp)
                    .resizable()
                    .scaledToFill()
                    .blur(radius: reduceTransparency ? 0 : 20)         // soft blur when allowed
                    .overlay(Color.black.opacity(reduceTransparency ? (scheme == .light ? 0.60 : 0.50)
                                                                    : (scheme == .light ? 0.40 : 0.35)))
                    .ignoresSafeArea()
            } else {
                // Fallback if wallpaper cannot be read
                Color.black.opacity(0.6).ignoresSafeArea()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSWorkspace.activeSpaceDidChangeNotification)) { _ in
            wallpaper = WallpaperProvider.currentScreenWallpaper()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in
            wallpaper = WallpaperProvider.currentScreenWallpaper()
        }
        .task {
            // refresh once window is on screen (screen may be nil on init)
            await MainActor.run {
                wallpaper = WallpaperProvider.currentScreenWallpaper()
            }
        }
    }
}

// Simple provider for current screen's desktop image
enum WallpaperProvider {
    static func currentScreenWallpaper() -> NSImage? {
        guard let screen = NSApp.keyWindow?.screen ?? NSScreen.main else { return nil }
        let ws = NSWorkspace.shared
        if let url = ws.desktopImageURL(for: screen),
           let img = NSImage(contentsOf: url) {
            return img
        }
        return nil
    }
}
