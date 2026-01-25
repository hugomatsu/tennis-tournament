#!/bin/bash

# iOS Production Build Script
# Generates a release build and IPA for App Store

set -e

echo "🚀 Building iOS Production..."

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

# Build release for iOS
echo "🏗️ Building iOS release..."
flutter build ios --release

# Create output directory
mkdir -p deploy/output

echo "✅ iOS Production build complete!"
echo "📍 Build location: build/ios/iphoneos/Runner.app"
echo ""
echo "📱 Next steps for App Store submission:"
echo "   1. Open ios/Runner.xcworkspace in Xcode"
echo "   2. Select 'Any iOS Device' as the destination"
echo "   3. Product > Archive"
echo "   4. Distribute App > App Store Connect"
echo ""
echo "🔐 Make sure you have:"
echo "   - Valid Apple Developer account"
echo "   - Correct signing certificates"
echo "   - App ID configured in App Store Connect"
