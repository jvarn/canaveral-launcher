import SwiftUI
import AppKit

@available(macOS 14.0, *)
struct ContentView: View {
    // MARK: - State
    @State private var searchText = ""
    @State private var currentPage = 0
    @State private var selectedAppIndex = 0
    @State private var slideFrom: Edge = .trailing
    
    // MARK: - Services
    @StateObject private var applicationLoader = ApplicationLoader()
    @StateObject private var appLauncher = AppLauncher()
    @StateObject private var windowManager = WindowManager()
    @StateObject private var keyboardHandler = KeyboardHandler()
    @StateObject private var scrollMonitor = ScrollMonitor()
    
    // MARK: - App Storage
    @AppStorage("iconSize") private var iconSize: Double = 128
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    
    // MARK: - Constants
    private let gridSpacing: CGFloat = 28
    private let sidePadding: CGFloat = 50
    private let topBottomPadding: CGFloat = 50
    private let searchBarApproxHeight: CGFloat = 56
    private let pageIndicatorApproxHeight: CGFloat = 32
    
    // MARK: - Computed Properties
    private var labelHeight: CGFloat { CGFloat(max(11, iconSize * 0.16) + 4) * 2.2 }
    private var cellWidth: CGFloat { CGFloat(iconSize + 16) }
    private var cellHeight: CGFloat { CGFloat(iconSize) + 8 + labelHeight }
    
    private var columnsCount: Int {
        let w = NSScreen.main?.frame.width ?? 1440
        let available = w - (sidePadding * 2)
        return max(3, Int(floor((available + gridSpacing) / (cellWidth + gridSpacing))))
    }
    
    private var rowsCount: Int {
        let h = NSScreen.main?.frame.height ?? 900
        let available = h - (topBottomPadding * 2) - searchBarApproxHeight - pageIndicatorApproxHeight
        return max(3, Int(floor((available + gridSpacing) / (cellHeight + gridSpacing))))
    }
    
    private var appsPerPage: Int { columnsCount * rowsCount }
    private var gridFixedHeight: CGFloat {
        CGFloat(rowsCount) * cellHeight + CGFloat(rowsCount - 1) * gridSpacing
    }
    
    private var filteredApplications: [Application] {
        if searchText.isEmpty {
            let startIndex = currentPage * appsPerPage
            let endIndex = min(startIndex + appsPerPage, applicationLoader.applications.count)
            return Array(applicationLoader.applications[startIndex..<endIndex])
        } else {
            return applicationLoader.applications.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    private var totalPages: Int {
        let count = searchText.isEmpty ? applicationLoader.applications.count : filteredApplications.count
        return max(1, (count + appsPerPage - 1) / appsPerPage)
    }
    
    private var pageSpring: Animation { .spring(response: 0.28, dampingFraction: 0.92) }
    
    // MARK: - Body
    var body: some View {
        ZStack {
            // Background
            Color.clear
                .background(LaunchpadBackdrop())
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Search bar
                SearchBar(searchText: $searchText) {
                    launchFirstFilteredApp()
                }
                .onChange(of: searchText) { _ in
                    currentPage = 0
                    selectedAppIndex = 0
                }
                
                // App grid with loading state
                if applicationLoader.isLoading {
                    LoadingView()
                } else {
                    slidingPage
                }
                
                // Page indicator
                PageIndicator(
                    currentPage: currentPage,
                    totalPages: totalPages,
                    onPageForward: pageForward,
                    onPageBackward: pageBackward
                )
            }
            .padding(50)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .allowsHitTesting(true)
        .contentShape(Rectangle())
        .onTapGesture {
            NSApplication.shared.terminate(nil)
        }
        .background(
            reduceTransparency ? AnyShapeStyle(Color(nsColor: .underPageBackgroundColor))
                               : AnyShapeStyle(.ultraThinMaterial)
        )
        .background(
            Rectangle()
                .fill(.ultraThinMaterial)
                .opacity(0.5)
                .ignoresSafeArea()
        )
        .onAppear {
            setupApp()
        }
        .onDisappear {
            scrollMonitor.stopMonitoring()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("CanaveralPreferencesChanged"))) { _ in
            Task {
                await applicationLoader.loadApplications()
            }
        }
        .onReceive(DistributedNotificationCenter.default().publisher(for: NSNotification.Name("CanaveralPreferencesChanged"))) { _ in
            Task {
                await applicationLoader.loadApplications()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSWindow.didBecomeKeyNotification)) { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                if let window = NSApplication.shared.windows.first {
                    window.focusSearchField()
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSWindow.didBecomeMainNotification)) { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                if let window = NSApplication.shared.windows.first {
                    window.focusSearchField()
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.willResignActiveNotification)) { _ in
            windowManager.hideApp()
        }
        .onKeyPress(phases: .down) { press in
            if #available(macOS 14.0, *) {
                return keyboardHandler.handleKeyPress(
                    press,
                    currentPage: $currentPage,
                    selectedAppIndex: $selectedAppIndex,
                    totalPages: totalPages,
                    filteredApplications: filteredApplications,
                    columnsCount: columnsCount
                )
            } else {
                return .ignored
            }
        }
        .gesture(
            DragGesture(minimumDistance: 30, coordinateSpace: .local)
                .onEnded { value in
                    handleDragGesture(value)
                }
        )
    }
    
    // MARK: - Views
    private var slidingPage: some View {
        ZStack {
            AppGrid(
                applications: filteredApplications,
                selectedAppIndex: selectedAppIndex,
                iconSize: iconSize,
                cellWidth: cellWidth,
                cellHeight: cellHeight,
                gridSpacing: gridSpacing,
                columnsCount: columnsCount,
                gridFixedHeight: gridFixedHeight,
                onAppSelected: { _ in },
                onAppTapped: { app in
                    appLauncher.launchApplication(app)
                }
            )
            .id(currentPage)
            .transition(.asymmetric(
                insertion: AnyTransition.move(edge: slideFrom).combined(with: .opacity),
                removal: AnyTransition.move(edge: slideFrom == .trailing ? .leading : .trailing).combined(with: .opacity)
            ))
        }
        .animation(pageSpring, value: currentPage)
    }
    
    // MARK: - Methods
    private func setupApp() {
        print("🚀 setupApp() called")
        
        // Start loading apps
        Task {
            print("🔄 Starting app loading task...")
            await applicationLoader.loadApplications()
        }
        
        // Setup window
        print("🪟 Setting up window...")
        windowManager.makeFullScreen()
        windowManager.setupWindowTransparency()
        
        // Setup scroll monitoring
        print("📱 Setting up scroll monitoring...")
        scrollMonitor.startMonitoring(
            currentPage: $currentPage,
            selectedAppIndex: $selectedAppIndex,
            totalPages: totalPages,
            searchText: searchText
        )
        
        // Focus search field
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if let window = NSApplication.shared.windows.first {
                window.focusSearchField()
            }
        }
        
        print("✅ setupApp() completed")
    }
    
    private func launchFirstFilteredApp() {
        appLauncher.launchFirstFilteredApp(
            from: filteredApplications,
            selectedIndex: selectedAppIndex
        )
    }
    
    private func pageForward() {
        guard currentPage < totalPages - 1 else { return }
        slideFrom = .trailing
        withAnimation(pageSpring) {
            currentPage += 1
            selectedAppIndex = 0
        }
    }
    
    private func pageBackward() {
        guard currentPage > 0 else { return }
        slideFrom = .leading
        withAnimation(pageSpring) {
            currentPage -= 1
            selectedAppIndex = 0
        }
    }
    
    private func handleDragGesture(_ value: DragGesture.Value) {
        let dx = value.translation.width
        let dy = value.translation.height
        guard abs(dx) > abs(dy), abs(dx) > 40 else { return }
        
        withAnimation(.spring(response: 0.25, dampingFraction: 0.9)) {
            if dx < 0 {
                // swipe left to next page
                if currentPage < totalPages - 1 {
                    currentPage += 1
                    selectedAppIndex = 0
                }
            } else {
                // swipe right to previous page
                if currentPage > 0 {
                    currentPage -= 1
                    selectedAppIndex = 0
                }
            }
        }
    }
}
