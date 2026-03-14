Bump the app version in pubspec.yaml and prepare it for a new release.

The version format is `major.minor.patch+buildNumber` (e.g. `1.0.0+1`).
- `versionName` (major.minor.patch) is shown to users in the store listing
- `buildNumber` (the +N part) maps to Android `versionCode` and must increase with every upload

## Usage
Call with one argument: `patch` (default), `minor`, or `major`
- `patch` — bug fixes: 1.0.0 → 1.0.1
- `minor` — new features: 1.0.0 → 1.1.0
- `major` — breaking changes: 1.0.0 → 2.0.0

The build number always increments by 1 regardless of bump type.

## Steps

1. Read the current version from pubspec.yaml:
```bash
grep "^version:" pubspec.yaml
```

2. Compute the new version based on the requested bump type (patch if not specified), increment the build number by 1, then update pubspec.yaml in-place:
```bash
python3 - <<'EOF'
import re, sys

bump = "$ARGUMENTS" if "$ARGUMENTS" else "patch"
if bump not in ("major", "minor", "patch"):
    print(f"Unknown bump type '{bump}'. Use: major, minor, patch"); sys.exit(1)

with open("pubspec.yaml", "r") as f:
    content = f.read()

m = re.search(r'^version:\s*(\d+)\.(\d+)\.(\d+)\+(\d+)', content, re.MULTILINE)
if not m:
    print("Could not parse version in pubspec.yaml"); sys.exit(1)

major, minor, patch, build = int(m.group(1)), int(m.group(2)), int(m.group(3)), int(m.group(4))
old = f"{major}.{minor}.{patch}+{build}"

if bump == "major":   major += 1; minor = 0; patch = 0
elif bump == "minor": minor += 1; patch = 0
else:                 patch += 1
build += 1

new = f"{major}.{minor}.{patch}+{build}"
content = content.replace(f"version: {old}", f"version: {new}", 1)

with open("pubspec.yaml", "w") as f:
    f.write(content)

print(f"Bumped: {old}  →  {new}")
EOF
```

3. Confirm the updated version:
```bash
grep "^version:" pubspec.yaml
```

Report the old and new version clearly. Remind the user to run `/google-play-release` or `/app-store-release` next to build and upload the new version.
