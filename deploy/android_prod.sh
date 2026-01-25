#!/bin/bash

# Android Production Build Script (APK)
# Generates a release APK for Android

set -e

echo "🚀 Building Android Production APK..."

# Navigate to project root
cd "$(dirname "$0")/.."

# Clean previous builds
echo "🧹 Cleaning previous builds..."
flutter clean

# Get dependencies
echo "📦 Getting dependencies..."
flutter pub get

# Build release APK
echo "🏗️ Building release APK..."
flutter build apk --release

# Copy to deploy folder
echo "📁 Copying to deploy folder..."
mkdir -p deploy/output
cp build/app/outputs/flutter-apk/app-release.apk deploy/output/tennis-tournament-release.apk

echo "✅ Android Production APK build complete!"
echo "📍 APK location: deploy/output/tennis-tournament-release.apk"
