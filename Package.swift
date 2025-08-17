// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Canaveral",
    platforms: [.macOS(.v13)],
    products: [.executable(name: "Canaveral", targets: ["Canaveral"])],
    targets: [
        .executableTarget(
            name: "Canaveral",
            path: "Canaveral",
            exclude: ["Info.plist"],
            sources: [
                "App/CanaveralApp.swift",
                "Views/BackdropView.swift",
                "Views/ContentView.swift",
                "Views/AppIconView.swift",
                "Models/Application.swift",
                "Services/ApplicationLoader.swift",
                "Services/AppLauncher.swift",
                "Services/WindowManager.swift",
                "Services/KeyboardHandler.swift",
                "Services/ScrollMonitor.swift",
                "Views/SearchBar.swift",
                "Views/AppGrid.swift",
                "Views/PageIndicator.swift",
                "Views/LoadingView.swift",
                "Utilities/Extensions.swift"
            ],
            resources: [
                .copy("Resources/AppIcon.icns"),
            ]
        )
    ]
)
