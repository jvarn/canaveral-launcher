#!/bin/bash
set -euo pipefail

echo "📱 Creating macOS App Bundle..."

# Must run from repo root (where Package.swift lives)
if [[ ! -f "Package.swift" ]]; then
  echo "❌ Error: run this from the repository root (where Package.swift is)."
  exit 1
fi

TARGET_DIR="Canaveral"                  # your source folder
BIN_PATH=".build/release/Canaveral"     # output from SwiftPM
APP_DIR="build/Canaveral.app"           # <-- now in root-level build/

# 1) Ensure binary exists
if [[ ! -x "$BIN_PATH" ]]; then
  echo "❌ Binary not found at $BIN_PATH"
  echo "👉 Run ./build_swift_simple.sh first."
  exit 1
fi

# 2) Recreate bundle skeleton
echo "🔨 Creating bundle: $APP_DIR"
rm -rf "$APP_DIR"
mkdir -p "$APP_DIR/Contents/MacOS" "$APP_DIR/Contents/Resources"

# 3) Copy binary
cp -f "$BIN_PATH" "$APP_DIR/Contents/MacOS/Canaveral"
chmod +x "$APP_DIR/Contents/MacOS/Canaveral"

# 4) Copy Info.plist
cp -f "$TARGET_DIR/Info.plist" "$APP_DIR/Contents/Info.plist"

# 5) Copy icon
ICON_SRC="$TARGET_DIR/Resources/AppIcon.icns"
cp -f "$ICON_SRC" "$APP_DIR/Contents/Resources/AppIcon.icns"

# 6) (Optional) ad-hoc codesign
if command -v codesign >/dev/null 2>&1; then
  echo "🔏 Codesigning (ad-hoc)…"
  codesign --force --deep --sign - "$APP_DIR"
fi

touch "$APP_DIR"

echo "✅ App bundle created"
echo "📍 $(pwd)/$APP_DIR"
echo "▶️  open '$APP_DIR'"
echo "📦 install: cp -r '$APP_DIR' /Applications/"
