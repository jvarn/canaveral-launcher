import Foundation
import AppKit

extension NSView {
    func findSearchField() -> NSTextField? {
        // Check if this view is a text field
        if let textField = self as? NSTextField {
            return textField
        }
        
        // Recursively search subviews
        for subview in subviews {
            if let found = subview.findSearchField() {
                return found
            }
        }
        return nil
    }
}

extension NSWindow {
    func focusSearchField() {
        if let searchField = contentView?.findSearchField() {
            makeFirstResponder(searchField)
            
            // Additional focus attempts
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.makeFirstResponder(searchField)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.makeFirstResponder(searchField)
            }
        }
    }
}
