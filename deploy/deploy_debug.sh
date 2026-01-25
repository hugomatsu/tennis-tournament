#!/bin/bash
# Deploy Debug Script
# Runs the app in debug mode with the Development environment overlay.

# Ensure we are in the project root
cd "$(dirname "$0")"

echo "🎾 Launching Tennis Tournament App (DEBUG / DEV)..."
echo "Targeting Chrome..."

flutter run -d chrome --dart-define=ENV=dev --web-renderer html

# To run on emulator:
# flutter run -d <device_id> --dart-define=ENV=dev
