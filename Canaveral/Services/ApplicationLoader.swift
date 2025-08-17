import Foundation
import AppKit

class ApplicationLoader: ObservableObject {
    @Published var applications: [Application] = []
    @Published var isLoading = false
    
    func loadApplications() async {
        print("🔄 Starting to load applications...")
        
        await MainActor.run {
            isLoading = true
        }
        
        // Run the heavy file system work on a background thread
        let apps = await Task.detached(priority: .userInitiated) {
            return self.loadApplicationsSync()
        }.value
        
        print("📱 Found \(apps.count) applications")
        
        await MainActor.run {
            applications = apps
            isLoading = false
            print("✅ Applications loaded successfully")
        }
    }
    
    private func loadApplicationsSync() -> [Application] {
        let fm = FileManager.default
        var roots: [URL] = [
            URL(fileURLWithPath: "/Applications"),
            URL(fileURLWithPath: "/System/Applications"),
            fm.homeDirectoryForCurrentUser.appendingPathComponent("Applications"),
            URL(fileURLWithPath: "/Applications/Utilities"),
            URL(fileURLWithPath: "/System/Applications/Utilities"),
            URL(fileURLWithPath: "/System/Library/CoreServices")
        ]
        
        // Safari and a few are here on modern macOS
        let cryptexRoot = URL(fileURLWithPath: "/System/Cryptexes/App/System/Applications")
        if fm.fileExists(atPath: cryptexRoot.path) {
            roots.append(cryptexRoot)
        }
        
        let keys: Set<URLResourceKey> = [.isApplicationKey, .isSymbolicLinkKey, .isPackageKey]
        let opts: FileManager.DirectoryEnumerationOptions = [.skipsHiddenFiles]
        
        var seen = Set<String>()
        var found: [Application] = []
        
        func addApp(_ url: URL) {
            guard let bundle = Bundle(url: url) else { 
                print("❌ No bundle for: \(url.path)")
                return 
            }
            
            // hide this app & apply rules
            guard isSupportedApp(at: url, bundle: bundle) else { 
                print("❌ App filtered out: \(url.lastPathComponent)")
                return 
            }
            
            let bundleID = bundle.bundleIdentifier ?? url.path
            guard !seen.contains(bundleID) else { 
                print("❌ Duplicate app: \(url.lastPathComponent)")
                return 
            }
            seen.insert(bundleID)
            
            let name = url.deletingPathExtension().lastPathComponent
            let icon = NSWorkspace.shared.icon(forFile: url.path)
            found.append(Application(name: name, path: url.path, icon: icon))
            print("✅ Added app: \(name)")
        }
        
        for root in roots {
            guard let enumerator = fm.enumerator(at: root, includingPropertiesForKeys: Array(keys), options: opts) else { continue }
            
            // Process enumerator directly to avoid conversion issues
            for case let url as URL in enumerator {
                do {
                    var vals = try url.resourceValues(forKeys: keys)
                    var appURL = url
                    
                    // Safari shows up as a symlink at /Applications – trying to resolve it
                    if vals.isSymbolicLink == true {
                        appURL = url.resolvingSymlinksInPath()
                        vals = try appURL.resourceValues(forKeys: keys)
                    }
                    
                    let looksLikeApp = (vals.isApplication == true) || appURL.pathExtension == "app"
                    guard looksLikeApp else { continue }
                    
                    // Don't descend into .app bundles
                    enumerator.skipDescendants()
                    
                    addApp(appURL)
                } catch {
                    continue
                }
            }
        }
        
        // de-dup by name (keep first), sort
        let uniqueApps = Array(Set(found.map { $0.name })).compactMap { name in
            found.first { $0.name == name }
        }
        return uniqueApps.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }
    
    // Plist bool reader (handles Bool / NSNumber / "true"/"false")
    private func plistBool(_ info: [String: Any], _ key: String, default defaultValue: Bool) -> Bool {
        if let b = info[key] as? Bool { return b }
        if let n = info[key] as? NSNumber { return n.boolValue }
        if let s = info[key] as? String { return (s as NSString).boolValue }
        return defaultValue
    }
    
    // Only show user-facing apps
    private func isUserFacingApp(_ bundle: Bundle) -> Bool {
        let info = bundle.infoDictionary ?? [:]
        
        // Background / UIElement helpers shouldn't appear
        if plistBool(info, "LSBackgroundOnly", default: false) { return false }
        if plistBool(info, "LSUIElement",     default: false) { return false }
        
        // Some Apple apps don't set this key so default to visible
        if plistBool(info, "LSVisibleInLaunchpad", default: true) == false { return false }
        
        // Must be proper application bundle
        if let pkgType = info["CFBundlePackageType"] as? String, pkgType != "APPL" {
            return false
        }
        return true
    }
    
    private func isSupportedApp(at url: URL, bundle: Bundle) -> Bool {
        // Never show self
        if let id = bundle.bundleIdentifier, id == Bundle.main.bundleIdentifier { return false }
        let baseName = url.deletingPathExtension().lastPathComponent
        if baseName == (Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String) {
            return false
        }
        
        // Plist-based rules
        guard isUserFacingApp(bundle) else { return false }
        
        // Skip helpers inside other apps
        let p = url.path
        if p.contains("/Contents/Library/LoginItems/") || p.contains("/Contents/XPCServices/") {
            return false
        }
        
        // CoreServices OFF by default but allowlist a few
        if p.hasPrefix("/System/Library/CoreServices/") {
            let allowed: Set<String> = [
                "Finder", "Screen Sharing", "Archive Utility",
                "Wireless Diagnostics", "Image Capture"
            ]
            return allowed.contains(baseName)
        }
        
        return true
    }
}
