---
description: Build and upload to Firebase App Distribution
---

# Firebase App Distribution Workflow

This workflow builds the Android APK in release mode and uploads it to Firebase App Distribution.

## Prerequisites
- Firebase CLI installed (`npm install -g firebase-tools`)
- You must be logged into Firebase (`firebase login`)
- The `testers` group should exist in your Firebase console (or you can adjust the group name in step 2)

## Steps

1. Stamp build_info.dart with the current version and UTC timestamp
```bash
// turbo
BUILD_VERSION=$(grep "^version:" pubspec.yaml | sed 's/version: //') && BUILD_TIME=$(date -u +"%Y-%m-%dT%H:%M:%SZ") && printf "// AUTO-GENERATED — do not edit manually.\n// Updated by the build script before each release build.\n// ignore_for_file: constant_identifier_names\n\nconst String kBuildVersion = '$BUILD_VERSION';\nconst String kBuildTime = '$BUILD_TIME';\n" > lib/core/build_info.dart
```

2. Build the Android APK
```bash
// turbo
flutter build apk --release
```

3. Upload to Firebase App Distribution
```bash
// turbo
firebase appdistribution:distribute build/app/outputs/flutter-apk/app-release.apk \
  --app 1:751059311860:android:e3c80454d4b5746f0c12a1 \
  --groups Devs
```
