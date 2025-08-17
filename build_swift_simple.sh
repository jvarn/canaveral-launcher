#!/bin/bash
set -euo pipefail

echo "🚀 Building Native macOS App Launcher with SwiftPM..."

# Must run from repo root (where Package.swift lives)
if [[ ! -f "Package.swift" ]]; then
  echo "❌ Error: run this from the repository root (where Package.swift is)."
  exit 1
fi

# Clean (optional) — uncomment if you want a fresh build each time
# swift package clean

# Build release
swift build -c release

BIN=".build/release/Canaveral"
if [[ ! -x "$BIN" ]]; then
  echo "❌ Build succeeded but binary not found at $BIN"
  exit 1
fi

echo "✅ Build complete"
echo "📦 Binary: $(pwd)/$BIN"
