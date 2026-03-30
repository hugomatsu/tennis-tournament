Build and deploy the Flutter web app to Firebase Hosting.

## Steps

1. Delete the Firebase hosting cache to force a full file comparison against the server (prevents stale deploys where the CLI skips uploading changed files because the local cache appears up-to-date):
```bash
rm -f .firebase/hosting.YnVpbGQvd2Vi.cache
```

2. Build the Flutter web app in release mode:
```bash
flutter build web --release
```

3. Deploy to Firebase Hosting:
```bash
firebase deploy --only hosting
```

Run all three steps sequentially and report the output including the hosting URL.
