Build a signed iOS App Store archive and upload it to App Store Connect (TestFlight by default).

## Prerequisites (first-time setup only)
- Xcode installed with a valid Apple Developer account signed in
- Fastlane installed: `gem install fastlane`
- An App Store Connect API key saved at `ios/app-store-connect-api-key.json`
  (Create one in App Store Connect → Users and Access → Integrations → App Store Connect API)
  The JSON must follow the format:
  ```json
  { "key_id": "XXXXXXXXXX", "issuer_id": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx", "key": "-----BEGIN EC PRIVATE KEY-----\n...\n-----END EC PRIVATE KEY-----" }
  ```
- The app must already exist in App Store Connect (bundle ID: com.hmlabs.tennis_tournament.tennis_tournament)

## Steps

1. Stamp build_info.dart with the current version and UTC timestamp:
```bash
BUILD_VERSION=$(grep "^version:" pubspec.yaml | sed 's/version: //') && BUILD_TIME=$(date -u +"%Y-%m-%dT%H:%M:%SZ") && printf "// AUTO-GENERATED — do not edit manually.\n// Updated by the build script before each release build.\n// ignore_for_file: constant_identifier_names\n\nconst String kBuildVersion = '$BUILD_VERSION';\nconst String kBuildTime = '$BUILD_TIME';\n" > lib/core/build_info.dart && echo "Stamped: v$BUILD_VERSION @ $BUILD_TIME"
```

2. Build the iOS release archive (IPA):
```bash
flutter build ipa --release
```

3. Upload the IPA to App Store Connect via fastlane deliver:
```bash
fastlane deliver \
  --ipa build/ios/ipa/*.ipa \
  --api_key_path ios/app-store-connect-api-key.json \
  --skip_metadata true \
  --skip_screenshots true \
  --skip_app_version_update true \
  --submit_for_review false \
  --force true
```

Run all three steps sequentially and report the output.
After a successful upload, remind the user to submit the build for review in App Store Connect if needed, or that it will be available in TestFlight shortly.
