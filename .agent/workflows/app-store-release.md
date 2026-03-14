---
description: Build IPA and upload to App Store Connect / TestFlight
---

# App Store Release Workflow

Builds a signed iOS IPA and uploads it to App Store Connect for TestFlight distribution or App Store review.

## Prerequisites
- Xcode + valid Apple Developer account signed in (`Preferences → Accounts`)
- Fastlane installed (`gem install fastlane`)
- `ios/app-store-connect-api-key.json` — App Store Connect API key
  - Create in App Store Connect → Users and Access → Integrations → App Store Connect API
  - Requires **App Manager** role
  - Save as JSON:
    ```json
    {
      "key_id": "XXXXXXXXXX",
      "issuer_id": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
      "key": "-----BEGIN EC PRIVATE KEY-----\n...\n-----END EC PRIVATE KEY-----"
    }
    ```
- App already created in App Store Connect with bundle ID `com.hmlabs.tennis_tournament.tennis_tournament`

## Distribution paths
| Destination | Use for |
|-------------|---------|
| TestFlight (internal) | Team testing — default, no review needed |
| TestFlight (external) | Beta testers — requires Beta App Review |
| App Store | Public release — requires full App Review |

## Steps

1. Stamp build_info.dart with the current version and UTC timestamp
```bash
// turbo
BUILD_VERSION=$(grep "^version:" pubspec.yaml | sed 's/version: //') && BUILD_TIME=$(date -u +"%Y-%m-%dT%H:%M:%SZ") && printf "// AUTO-GENERATED — do not edit manually.\n// Updated by the build script before each release build.\n// ignore_for_file: constant_identifier_names\n\nconst String kBuildVersion = '$BUILD_VERSION';\nconst String kBuildTime = '$BUILD_TIME';\n" > lib/core/build_info.dart
```

2. Build the iOS IPA
```bash
// turbo
flutter build ipa --release
```

3. Upload to App Store Connect via fastlane deliver
```bash
// turbo
fastlane deliver \
  --ipa build/ios/ipa/*.ipa \
  --api_key_path ios/app-store-connect-api-key.json \
  --skip_metadata true \
  --skip_screenshots true \
  --skip_app_version_update true \
  --submit_for_review false \
  --force true
```

## Submit for App Store review (manual step in App Store Connect)
After the build is processed in TestFlight (usually ~10 min), go to:
App Store Connect → Entre Sets → Distribution → App Store → + Version → select the build → Submit for Review
