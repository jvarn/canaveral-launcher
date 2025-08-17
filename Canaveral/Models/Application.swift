import Foundation
import AppKit

struct Application: Identifiable {
    let id = UUID()
    let name: String
    let path: String
    let icon: NSImage?
}
