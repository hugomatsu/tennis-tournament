#!/bin/bash

# Web Debug Build + Firebase Deploy Script
# Builds debug version and deploys to Firebase Hosting

set -e

echo "🔧 Building Web Debug + Deploying to Firebase..."

# Navigate to project root
cd "$(dirname "$0")/.."

# Clean previous builds
echo "🧹 Cleaning previous builds..."
flutter clean

# Get dependencies
echo "📦 Getting dependencies..."
flutter pub get

# Build web debug (using profile for better debugging with decent performance)
echo "🏗️ Building web..."
flutter build web --profile

# Copy to deploy folder
echo "📁 Copying to deploy folder..."
mkdir -p deploy/output/web-debug
cp -r build/web/* deploy/output/web-debug/

# Deploy to Firebase Hosting
echo "🔥 Deploying to Firebase Hosting..."
firebase deploy --only hosting

echo "✅ Web Debug build + Firebase deploy complete!"
echo ""
echo "🌐 Your app should now be live at your Firebase Hosting URL"
echo "   Check the output above for the exact URL"
