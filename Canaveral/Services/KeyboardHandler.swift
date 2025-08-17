import Foundation
import SwiftUI

@available(macOS 14.0, *)
class KeyboardHandler: ObservableObject {
    
    func handleKeyPress(_ press: KeyPress, 
                        currentPage: Binding<Int>,
                        selectedAppIndex: Binding<Int>,
                        totalPages: Int,
                        filteredApplications: [Application],
                        columnsCount: Int) -> KeyPress.Result {
        
        switch press.key {
        case .escape:
            // Properly quit app to avoid state corruption
            NSApplication.shared.terminate(nil)
            return .handled
            
        case .leftArrow:
            print("Left arrow pressed - currentPage: \(currentPage.wrappedValue), selectedIndex: \(selectedAppIndex.wrappedValue)")
            
            // Check if shift is pressed for page nav, else app nav
            if press.modifiers.contains(.shift) {
                print("Shift+Left: Moving to previous page")
                // Move to previous page
                if currentPage.wrappedValue > 0 {
                    currentPage.wrappedValue -= 1
                    selectedAppIndex.wrappedValue = 0
                }
                return .handled
            } else {
                // Check if we're at top left (first icon on current page)
                let cols = max(1, columnsCount) // Prevent division by zero
                let currentRow = selectedAppIndex.wrappedValue / cols
                let currentCol = selectedAppIndex.wrappedValue % cols
                let isFirstIconOnPage = currentRow == 0 && currentCol == 0
                let haspageBackward = currentPage.wrappedValue > 0
                
                print("Left arrow - cols: \(cols), currentRow: \(currentRow), isFirstIconOnPage: \(isFirstIconOnPage), haspageBackward: \(haspageBackward)")
                
                if isFirstIconOnPage && haspageBackward {
                    print("Going to previous page")
                    // Go to prev page, ending at bottom right
                    let newPage = currentPage.wrappedValue - 1
                    currentPage.wrappedValue = newPage
                    // Calculate last icon index on prev page
                    let pageBackwardApps = getAppsForPage(newPage, appsPerPage: columnsCount * 5, applications: filteredApplications)
                    if !pageBackwardApps.isEmpty {
                        selectedAppIndex.wrappedValue = pageBackwardApps.count - 1
                    } else {
                        selectedAppIndex.wrappedValue = 0
                    }
                    print("Now on page \(currentPage.wrappedValue), selectedIndex: \(selectedAppIndex.wrappedValue)")
                } else {
                    print("Moving to previous app icon")
                    // Move to prev app icon (with wrapping)
                    if !filteredApplications.isEmpty {
                        selectedAppIndex.wrappedValue = selectedAppIndex.wrappedValue > 0 ? selectedAppIndex.wrappedValue - 1 : filteredApplications.count - 1
                    }
                }
                return .handled
            }
            
        case .rightArrow:
            print("Right arrow pressed - currentPage: \(currentPage.wrappedValue), selectedIndex: \(selectedAppIndex.wrappedValue)")
            
            // Check if shift is pressed for page nav, else app nav
            if press.modifiers.contains(.shift) {
                print("Shift+Right: Moving to next page")
                // Move to next page
                if currentPage.wrappedValue < totalPages - 1 {
                    currentPage.wrappedValue += 1
                    selectedAppIndex.wrappedValue = 0
                }
                return .handled
            } else {
                // Check if we're at the bottom right (last icon on current page)
                let cols = max(1, columnsCount) // Prevent division by zero
                let currentRow = selectedAppIndex.wrappedValue / cols
                let currentCol = selectedAppIndex.wrappedValue % cols
                let maxRow = max(0, (filteredApplications.count - 1) / cols)
                let isLastIconOnPage = currentRow == maxRow && currentCol == (cols - 1)
                let haspageForward = currentPage.wrappedValue < totalPages - 1
                
                print("Right arrow - cols: \(cols), currentRow: \(currentRow), maxRow: \(maxRow), isLastIconOnPage: \(isLastIconOnPage), haspageForward: \(haspageForward)")
                
                if isLastIconOnPage && haspageForward {
                    print("Going to next page")
                    // Go to next page, starting at top left
                    let newPage = currentPage.wrappedValue + 1
                    currentPage.wrappedValue = newPage
                    selectedAppIndex.wrappedValue = 0
                } else {
                    print("Moving to next app icon")
                    // Move to next app icon (with wrapping)
                    if !filteredApplications.isEmpty {
                        selectedAppIndex.wrappedValue = (selectedAppIndex.wrappedValue + 1) % filteredApplications.count
                    }
                }
                return .handled
            }
            
        case .upArrow:
            if !filteredApplications.isEmpty {
                let cols = max(1, columnsCount) // Prevent division by zero
                let currentRow = selectedAppIndex.wrappedValue / cols
                let currentCol = selectedAppIndex.wrappedValue % cols
                let maxRow = max(0, (filteredApplications.count - 1) / cols)
                
                let newRow = currentRow > 0 ? currentRow - 1 : maxRow
                var newIndex = newRow * cols + currentCol
                if newIndex >= filteredApplications.count { newIndex = filteredApplications.count - 1 }
                selectedAppIndex.wrappedValue = newIndex
            }
            return .handled
            
        case .downArrow:
            if !filteredApplications.isEmpty {
                let cols = max(1, columnsCount) // Prevent division by zero
                let currentRow = selectedAppIndex.wrappedValue / cols
                let currentCol = selectedAppIndex.wrappedValue % cols
                let maxRow = max(0, (filteredApplications.count - 1) / cols)
                
                let newRow = currentRow < maxRow ? currentRow + 1 : 0
                var newIndex = newRow * cols + currentCol
                if newIndex >= filteredApplications.count { newIndex = filteredApplications.count - 1 }
                selectedAppIndex.wrappedValue = newIndex
            }
            return .handled
            
        case .tab:
            // Move to next app icon
            if !filteredApplications.isEmpty {
                selectedAppIndex.wrappedValue = (selectedAppIndex.wrappedValue + 1) % filteredApplications.count
            }
            return .handled
            
        default:
            return .ignored
        }
    }
    
    private func getAppsForPage(_ page: Int, appsPerPage: Int, applications: [Application]) -> [Application] {
        // Safety check: page must be non-negative
        guard page >= 0 else { return [] }
        
        let startIndex = page * appsPerPage
        let endIndex = min(startIndex + appsPerPage, applications.count)
        
        // Safety check: startIndex must be within bounds
        guard startIndex < applications.count else { return [] }
        
        return Array(applications[startIndex..<endIndex])
    }
}
