#!/bin/bash
# Deploy Production Script
# Builds the app for release with the Production environment overlay.

# Ensure we are in the project root
cd "$(dirname "$0")"

echo "🎾 Building Tennis Tournament App (RELEASE / PROD)..."

# Web Build
echo "Building for Web..."
flutter build web --release --dart-define=ENV=prod --web-renderer html

# Android App Bundle (Uncomment if needed)
# echo "Building for Android..."
# flutter build appbundle --release --dart-define=ENV=prod

# iOS IPA (Uncomment if needed, requires macOS)
# echo "Building for iOS..."
# flutter build ipa --release --dart-define=ENV=prod

echo "✅ Build Complete!"
echo "Web build located at: build/web"
