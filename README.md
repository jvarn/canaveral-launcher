# Canaveral

Canaveral is a full-screen, grid-based app launcher for macOS.

Canaveral is a simple, full-screen app grid for macOS. It lets you browse and search your applications in a large, clear interface — ideal for use on TVs or other big displays where Apple’s new Spotlight-based launcher can feel too small.

Inspired by Launchpad, iPadOS, and GNOME 3, Canaveral focuses on fast keyboard search and a distance-friendly grid layout.

## Features

- **Full-screen app grid**  
  Browse all your installed applications in a large, clear grid layout, ideal for TVs and big displays.  
  Only user-facing apps are shown, while background agents and system utilities are filtered out automatically.

- **Navigation**  
  - **Launching apps:**  
    Type in the search box and press Return, or use the arrow keys + Return for quick keyboard control.  
  - **Changing pages:**  
    Swipe with a trackpad (two-finger swipe or click-and-drag), use Shift+arrow keys, or click the pagination buttons.
    
- **Lightweight by design**  
  Canaveral quits after launching an app, but its lightweight design and streamlined architecture allow for quick subsequent launches.

## Installation

The easiest way to try Canaveral is to download a pre-compiled app bundle from the
[Releases page](../../releases).

1. Download the latest `.zip` or `.dmg` file.
2. Unzip or mount it and drag **Canaveral.app** into your Applications folder.
3. Launch it from Spotlight, Finder, or a hotkey of your choice.

Canaveral can also be built from source (see [Building](#building) below).

## Project Structure

Canaveral is organized into logical modules for maintainability:

- **App/**: Main application entry point
- **Models/**: Data structures and models  
- **Services/**: Business logic and app functionality
- **Views/**: SwiftUI view components
- **Utilities/**: Helper functions and extensions
- **Resources/**: App icons and assets

## How It Works

Canaveral is built with Swift and SwiftUI. Its core functionality includes:

1. **App discovery**  
   Applications are collected from standard system locations, including:
   - `/Applications`
   - `/System/Applications`
   - User application directories  
   Certain system utilities and background agents are excluded to keep the list user-facing.

2. **Search and filtering**  
   - A search bar at the top filters the grid in real time.
   - Searching is the primary means of finding apps.

3. **Navigation and launching**  
   - Arrow keys, Return, and Escape are supported for keyboard control.
   - Pagination works via:
     - Pagination buttons
     - Shift+arrow keys
     - Trackpad swipes
     - Trackpage or mouse click and drag

4. **Exit conditions**  
   Canaveral automatically quits when:
   - An app is launched
   - Escape is pressed
   - The background is clicked
   - The app loses focus (e.g. via Command-Tab)

5. **Background operation**  
   Canaveral can run as a background app without showing in the dock, providing faster subsequent launches.

## Building

You can build Canaveral either with Swift Package Manager or through Xcode.

### Requirements
- macOS 13 or later
- Swift 5.9+

### Build with SwiftPM

From the project root:

```bash
./build_swift_simple.sh
./create_app_bundle.sh
open build/Canaveral.app

