Build and upload the Android APK to Firebase App Distribution.

## Steps

1. Bump the build number in pubspec.yaml (keeps the version name, increments only the build number):
```bash
python3 - <<'EOF'
import re, sys
with open("pubspec.yaml", "r") as f:
    content = f.read()
m = re.search(r'^version:\s*(\d+\.\d+\.\d+)\+(\d+)', content, re.MULTILINE)
if not m:
    print("Could not parse version"); sys.exit(1)
version_name, build = m.group(1), int(m.group(2))
old = f"{version_name}+{build}"
new = f"{version_name}+{build + 1}"
content = content.replace(f"version: {old}", f"version: {new}", 1)
with open("pubspec.yaml", "w") as f:
    f.write(content)
print(f"Bumped: {old}  →  {new}")
EOF
```

2. Stamp build_info.dart with the current version and UTC timestamp:
```bash
BUILD_VERSION=$(grep "^version:" pubspec.yaml | sed 's/version: //') && BUILD_TIME=$(date -u +"%Y-%m-%dT%H:%M:%SZ") && printf "// AUTO-GENERATED — do not edit manually.\n// Updated by the build script before each release build.\n// ignore_for_file: constant_identifier_names\n\nconst String kBuildVersion = '$BUILD_VERSION';\nconst String kBuildTime = '$BUILD_TIME';\n" > lib/core/build_info.dart && echo "Stamped: v$BUILD_VERSION @ $BUILD_TIME"
```

3. Build the Android APK in release mode:
```bash
flutter build apk --release
```

4. Upload to Firebase App Distribution:
```bash
firebase appdistribution:distribute build/app/outputs/flutter-apk/app-release.apk \
  --app 1:751059311860:android:e3c80454d4b5746f0c12a1 \
  --groups Devs
```

Run all four steps sequentially and report the output including the new build number.
