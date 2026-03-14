---
description: Build AAB and upload to Google Play Store
---

# Google Play Release Workflow

Builds a signed Android App Bundle and uploads it to the Google Play Store internal track.

## Prerequisites
- Fastlane installed (`gem install fastlane`)
- `android/play-service-account.json` — Google Play service account key
  - Create in Play Console → Setup → API access → Service accounts → Grant permissions (Release Manager)
  - Download the JSON key and save it at the path above
- `android/key.properties` + `android/app/upload-keystore.jks` — release signing (already configured)
- App must have at least one manual release published before the API can upload

## Tracks
| Track | Use for |
|-------|---------|
| `internal` | Team testing (up to 100 testers) — default |
| `alpha` | Closed testing |
| `beta` | Open testing |
| `production` | Public release |

## Steps

1. Stamp build_info.dart with the current version and UTC timestamp
```bash
// turbo
BUILD_VERSION=$(grep "^version:" pubspec.yaml | sed 's/version: //') && BUILD_TIME=$(date -u +"%Y-%m-%dT%H:%M:%SZ") && printf "// AUTO-GENERATED — do not edit manually.\n// Updated by the build script before each release build.\n// ignore_for_file: constant_identifier_names\n\nconst String kBuildVersion = '$BUILD_VERSION';\nconst String kBuildTime = '$BUILD_TIME';\n" > lib/core/build_info.dart
```

2. Build the Android App Bundle
```bash
// turbo
flutter build appbundle --release
```

3. Upload to Google Play (internal track)
```bash
// turbo
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

## Promote to production (manual step in Play Console)
After the internal release is verified, go to:
Google Play Console → Entre Sets → Testing → Internal testing → Promote release
