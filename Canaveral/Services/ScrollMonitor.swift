import Foundation
import AppKit
import SwiftUI

class ScrollMonitor: ObservableObject {
    private var monitor: Any?
    @Published var swipeAccumX: CGFloat = 0
    
    func startMonitoring(currentPage: Binding<Int>, 
                        selectedAppIndex: Binding<Int>,
                        totalPages: Int,
                        searchText: String) {
        
        guard monitor == nil else { return }
        
        monitor = NSEvent.addLocalMonitorForEvents(matching: .scrollWheel) { event in
            // Only when launcher is active and not searching
            guard NSApp.isActive, searchText.isEmpty else { return event }
            
            // Treat horizontal two-finger motion as swipe and accumulate until end
            let phase: NSEvent.Phase = (event.phase != []) ? event.phase : event.momentumPhase
            
            if phase == .began {
                self.swipeAccumX = 0
            }
            
            if phase == .changed {
                // Trackpads usually set hasPreciseScrollingDeltas = true; keep scale = 1.0
                let scale: CGFloat = event.hasPreciseScrollingDeltas ? 1.0 : 10.0
                self.swipeAccumX += event.scrollingDeltaX * scale
            }
            
            if phase == .ended {
                let threshold: CGFloat = 120   // 100–180 feels good
                if self.swipeAccumX <= -threshold {
                    // swipe left to next page
                    if currentPage.wrappedValue < totalPages - 1 {
                        withAnimation(.spring(response: 0.25, dampingFraction: 0.9)) {
                            currentPage.wrappedValue += 1
                            selectedAppIndex.wrappedValue = 0
                        }
                        NSHapticFeedbackManager.defaultPerformer.perform(.generic, performanceTime: .now)
                    }
                    self.swipeAccumX = 0
                    return nil
                } else if self.swipeAccumX >= threshold {
                    // swipe right to previous page
                    if currentPage.wrappedValue > 0 {
                        withAnimation(.spring(response: 0.25, dampingFraction: 0.9)) {
                            currentPage.wrappedValue -= 1
                            selectedAppIndex.wrappedValue = 0
                        }
                        NSHapticFeedbackManager.defaultPerformer.perform(.generic, performanceTime: .now)
                    }
                    self.swipeAccumX = 0
                    return nil
                }
                // reset even if threshold not hit
                self.swipeAccumX = 0
            }
            return event
        }
    }
    
    func stopMonitoring() {
        if let monitor = monitor {
            NSEvent.removeMonitor(monitor)
            self.monitor = nil
        }
    }
    
    deinit {
        stopMonitoring()
    }
}
