# Publishing Guide for Tennis Tournament App

This guide covers the steps to publish the Tennis Tournament application for Web (Firebase Hosting), Android, and iOS.

## Prerequisites

- Flutter SDK installed and configured.
- Firebase CLI installed (`npm install -g firebase-tools`).
- Apple Developer Account (for iOS).
- Google Play Console Account (for Android).
- Xcode (for iOS build).
- Android Studio (for Android build).

---

## 1. Web (Firebase Hosting)

### Build for Web

1.  Run the build command:
    ```bash
    flutter build web --release
    ```
    *Note: Ensure your `assets/env` file is present and contains the necessary Firebase configuration keys.*

### Deploy to Firebase

1.  Login to Firebase:
    ```bash
    firebase login
    ```

2.  Initialize Firebase (if not already done):
    ```bash
    firebase init hosting
    ```
    - Select your project.
    - Public directory: `build/web`
    - Configure as a single-page app: `Yes`
    - Set up automatic builds and deploys with GitHub? (Optional)

3.  Deploy:
    ```bash
    firebase deploy --only hosting
    ```

---

## 2. Android (Google Play Store)

### Key Signing

1.  Create a keystore file (if you haven't already):
    ```bash
    keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
    ```
2.  Create a file named `key.properties` in the `android/` directory:
    ```properties
    storePassword=<your-store-password>
    keyPassword=<your-key-password>
    keyAlias=upload
    storeFile=<path-to-keystore>
    ```
3.  Configure `android/app/build.gradle` to use the keystore (refer to [Flutter docs](https://docs.flutter.dev/deployment/android#configure-signing-in-gradle)).

### Build App Bundle

1.  Run the build command:
    ```bash
    flutter build appbundle --release
    ```
    The output file will be at `build/app/outputs/bundle/release/app-release.aab`.

### Upload to Play Console

1.  Go to [Google Play Console](https://play.google.com/console).
2.  Create a new app or select an existing one.
3.  Navigate to **Production** (or Testing tracks).
4.  Create a new release and upload the `.aab` file.
5.  Complete the store listing details and roll out.

---

## 3. iOS (App Store)

### Configuration

1.  Open `ios/Runner.xcworkspace` in Xcode.
2.  Select the **Runner** target.
3.  In the **Signing & Capabilities** tab, ensure your Team is selected and "Automatically manage signing" is checked.
4.  Update the **Bundle Identifier** and **Version** if needed.

### Build Archive

1.  In Xcode, select **Product > Destination > Any iOS Device (arm64)**.
2.  Select **Product > Archive**.
3.  Wait for the build to complete. The Organizer window will open.

### Upload to App Store Connect

1.  In the Organizer, select your archive and click **Distribute App**.
2.  Select **App Store Connect** and follow the prompts (Upload).
3.  Once uploaded, go to [App Store Connect](https://appstoreconnect.apple.com/).
4.  Select your app, go to **TestFlight** to test, or **App Store** to create a production release.
5.  Select the build you uploaded and submit for review.
