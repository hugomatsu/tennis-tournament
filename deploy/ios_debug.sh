#!/bin/bash

# iOS Debug Build Script
# Generates a debug build for iOS Simulator

set -e

echo "🔧 Building iOS Debug..."

# Navigate to project root
cd "$(dirname "$0")/.."

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "❌ iOS builds require macOS"
    exit 1
fi

# Clean previous builds
echo "🧹 Cleaning previous builds..."
flutter clean

# Get dependencies
echo "📦 Getting dependencies..."
flutter pub get

# Install CocoaPods dependencies
echo "🍫 Installing CocoaPods..."
cd ios && pod install && cd ..

# Build debug for iOS
echo "🏗️ Building iOS debug..."
flutter build ios --debug --no-codesign

echo "✅ iOS Debug build complete!"
echo "📍 Build location: build/ios/iphoneos/Runner.app"
echo ""
echo "📱 To run on simulator: flutter run -d <simulator_id>"
echo "   List simulators: flutter devices"
