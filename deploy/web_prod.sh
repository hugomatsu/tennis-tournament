#!/bin/bash

# Web Production Build Script
# Generates a release build for web deployment

set -e

echo "🚀 Building Web Production..."

# Navigate to project root
cd "$(dirname "$0")/.."

# Clean previous builds
echo "🧹 Cleaning previous builds..."
flutter clean

# Get dependencies
echo "📦 Getting dependencies..."
flutter pub get

# Build web release with optimizations
echo "🏗️ Building web release..."
flutter build web --release --web-renderer canvaskit --tree-shake-icons

# Copy to deploy folder
echo "📁 Copying to deploy folder..."
mkdir -p deploy/output/web-prod
cp -r build/web/* deploy/output/web-prod/

echo "✅ Web Production build complete!"
echo "📍 Build location: deploy/output/web-prod/"
echo ""
echo "🌐 Deployment options:"
echo "   Firebase Hosting: firebase deploy --only hosting"
echo "   Vercel: vercel deploy deploy/output/web-prod"
echo "   Netlify: netlify deploy --dir=deploy/output/web-prod"
echo ""
echo "📄 Files to deploy:"
ls -la deploy/output/web-prod/
