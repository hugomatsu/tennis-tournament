#!/bin/bash

# Android Debug Build Script
# Generates a debug APK for Android

set -e

echo "🔧 Building Android Debug APK..."

# Navigate to project root
cd "$(dirname "$0")/.."

# Clean previous builds
echo "🧹 Cleaning previous builds..."
flutter clean

# Get dependencies
echo "📦 Getting dependencies..."
flutter pub get

# Build debug APK
echo "🏗️ Building debug APK..."
flutter build apk --debug

# Copy to deploy folder
echo "📁 Copying to deploy folder..."
mkdir -p deploy/output
cp build/app/outputs/flutter-apk/app-debug.apk deploy/output/tennis-tournament-debug.apk

echo "✅ Android Debug build complete!"
echo "📍 APK location: deploy/output/tennis-tournament-debug.apk"
