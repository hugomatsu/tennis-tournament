#!/bin/bash

# Android Production Build Script (AAB)
# Generates a release App Bundle for Google Play Store

set -e

echo "🚀 Building Android Production AAB..."

# Navigate to project root
cd "$(dirname "$0")/.."

# Clean previous builds
echo "🧹 Cleaning previous builds..."
flutter clean

# Get dependencies
echo "📦 Getting dependencies..."
flutter pub get

# Build release App Bundle
echo "🏗️ Building release App Bundle..."
flutter build appbundle --release

# Copy to deploy folder
echo "📁 Copying to deploy folder..."
mkdir -p deploy/output
cp build/app/outputs/bundle/release/app-release.aab deploy/output/tennis-tournament-release.aab

echo "✅ Android Production AAB build complete!"
echo "📍 AAB location: deploy/output/tennis-tournament-release.aab"
echo ""
echo "📱 Upload this file to Google Play Console for distribution."
