---
name: Do not auto-build APK
description: Never trigger an Android APK build unless the user explicitly asks for it
type: feedback
---

Never build the Android APK automatically. Only run the build and distribution steps when the user explicitly requests it.

**Why:** The user prefers to control when builds happen.

**How to apply:** After completing code changes, do not invoke the android-build-app-distribution skill or run `flutter build apk` unless directly asked.
