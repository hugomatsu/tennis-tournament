Build and upload the Android APK to Firebase App Distribution.

## Steps

1. Build the Android APK in release mode:
```bash
flutter build apk --release
```

2. Upload to Firebase App Distribution:
```bash
firebase appdistribution:distribute build/app/outputs/flutter-apk/app-release.apk \
  --app 1:751059311860:android:e3c80454d4b5746f0c12a1 \
  --groups Devs
```

Run both commands sequentially and report the output.
