Build a signed Android App Bundle and upload it to Google Play Store (internal track by default).

## Prerequisites (first-time setup only)
- Fastlane installed: `gem install fastlane`
- A Google Play service-account JSON key saved at `android/play-service-account.json`
  (Create one in Google Play Console → Setup → API access → Service accounts)
- The app must already have at least one manual release in Play Console before the API can upload

## Steps

1. Stamp build_info.dart with the current version and UTC timestamp:
```bash
BUILD_VERSION=$(grep "^version:" pubspec.yaml | sed 's/version: //') && BUILD_TIME=$(date -u +"%Y-%m-%dT%H:%M:%SZ") && printf "// AUTO-GENERATED — do not edit manually.\n// Updated by the build script before each release build.\n// ignore_for_file: constant_identifier_names\n\nconst String kBuildVersion = '$BUILD_VERSION';\nconst String kBuildTime = '$BUILD_TIME';\n" > lib/core/build_info.dart && echo "Stamped: v$BUILD_VERSION @ $BUILD_TIME"
```

2. Build the Android App Bundle (AAB) in release mode:
```bash
flutter build appbundle --release
```

3. Upload the AAB to Google Play internal track via fastlane supply:
```bash
fastlane supply \
  --aab build/app/outputs/bundle/release/app-release.aab \
  --track internal \
  --package_name com.hmlabs.tennis_tournament.tennis_tournament \
  --json_key android/play-service-account.json \
  --skip_upload_apk true \
  --skip_upload_metadata true \
  --skip_upload_images true \
  --skip_upload_screenshots true
```

Run all three steps sequentially and report the output.
After a successful upload, remind the user to promote the release to alpha/beta/production in the Google Play Console if needed.
