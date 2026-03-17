---
description: Bump version, build AAB, and upload to Google Play Store
---

# Android Distribute Workflow

Full release pipeline: bumps the patch version, builds a signed AAB, and uploads to the chosen Google Play track.

## Tracks
| Track | Audience | Review required |
|-------|----------|-----------------|
| `internal` | Up to 100 testers (team) | No |
| `alpha` | Closed testers (invited) | No |
| `beta` | Open testers (anyone) | Beta App Review |
| `production` | All Play Store users | Full App Review |

## Prerequisites
- Fastlane installed (`gem install fastlane`)
- `android/play-service-account.json` — Google Play service account key with **Release Manager** role
- App already exists in Play Console with bundle ID `com.hmlabs.tennis_tournament.tennis_tournament`
- At least one manual release published before API uploads are possible

## Steps

1. Bump patch version + build number
```bash
// turbo
python3 - <<'EOF'
import re, sys
with open("pubspec.yaml", "r") as f:
    content = f.read()
m = re.search(r'^version:\s*(\d+)\.(\d+)\.(\d+)\+(\d+)', content, re.MULTILINE)
if not m:
    print("Could not parse version"); sys.exit(1)
major, minor, patch, build = int(m.group(1)), int(m.group(2)), int(m.group(3)), int(m.group(4))
old = f"{major}.{minor}.{patch}+{build}"
patch += 1; build += 1
new = f"{major}.{minor}.{patch}+{build}"
content = content.replace(f"version: {old}", f"version: {new}", 1)
with open("pubspec.yaml", "w") as f:
    f.write(content)
print(f"Bumped: {old}  →  {new}")
EOF
```

2. Stamp build_info.dart
```bash
// turbo
BUILD_VERSION=$(grep "^version:" pubspec.yaml | sed 's/version: //') && BUILD_TIME=$(date -u +"%Y-%m-%dT%H:%M:%SZ") && printf "// AUTO-GENERATED — do not edit manually.\n// Updated by the build script before each release build.\n// ignore_for_file: constant_identifier_names\n\nconst String kBuildVersion = '$BUILD_VERSION';\nconst String kBuildTime = '$BUILD_TIME';\n" > lib/core/build_info.dart
```

3. Build AAB
```bash
// turbo
flutter build appbundle --release
```

4. Upload to Google Play (track passed as argument, defaults to internal)
```bash
// turbo
TRACK="${ARGUMENTS:-internal}"
fastlane supply \
  --aab build/app/outputs/bundle/release/app-release.aab \
  --track "$TRACK" \
  --package_name com.hmlabs.tennis_tournament.tennis_tournament \
  --json_key android/play-service-account.json \
  --skip_upload_apk true \
  --skip_upload_metadata true \
  --skip_upload_images true \
  --skip_upload_screenshots true
```

## Promote to a higher track (manual — Play Console)
Play Console → Entre Sets → Testing / Production → select the release → **Promote release**
