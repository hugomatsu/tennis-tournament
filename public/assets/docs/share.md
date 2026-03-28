# Share Feature Design

## 1. Overview
**Goal**: Implement a robust, cross-platform "Social Sharing" feature for the Flutter Tournament App (Web, Android, iOS) that rivals top market competitors. The feature will allow users to invite players, share visual brackets, and share victory cards.

## 2. Technical Architecture

### Core Dependencies
(Already present in `pubspec.yaml` or to be added)
- **`share_plus`**: For triggering native share sheets on Android/iOS.
- **`screenshot`** (or `RepaintBoundary`): To capture specific widgets (brackets, scorecards) as images before sharing.
- **`path_provider`**: To save captured images to temporary storage before sharing (Mobile only).
- **`url_launcher`**: For handling fallback intent URLs on Desktop Web.
- **`go_router`**: For deep linking handling (`/t/:id` -> `/tournaments/:id`).

### Platform-Specific Strategy

#### A. Mobile (Android & iOS)
- **Images**: Use `Share.shareXFiles` (from `share_plus`) to share captured brackets/cards.
- **Text/Links**: Use `Share.share` for simple invite links.
- **Outcome**: Opens the native system share sheet.

#### B. Web (Browser)
*Current constraint: `navigator.share` is inconsistent on Desktop.*
**Strategy: "Tri-State Fallback"**
1.  **Try Native**: Attempt `await Share.share(...)`.
2.  **Catch Failure**: If it fails or is unsupported exceptions, trigger a custom **Fallback Share Dialog**.
3.  **Fallback UI**:
    - "Copy Link" (Write to Clipboard).
    - "Share to X/Twitter" (URL Scheme).
    - "Share to WhatsApp" (URL Scheme).
    - "Download Image" (For visual artifacts like brackets).

## 3. High-Level Requirements

### Feature 1: The "Invite Link" (Lobby)
- **Location**: Tournament Lobby Screen.
- **Action**: User clicks "Invite Players".
- **Behavior**:
    - Generates a **Deep Link**: `https://yourapp.com/t/{tournament_id}` (needs new route alias).
    - **Mobile**: Opens share sheet with pre-filled text: *"Join my tournament on [AppName]! Code: {code} {link}"*.
    - **Web**: Fallback to Copy Link / Social options.

### Feature 2: The "Visual Bracket" (During Event)
- **Location**: Bracket View / Standings.
- **Action**: User clicks "Share Bracket".
- **Behavior**:
    - **Capture**: Takes a screenshot of the entire bracket widget (rendering off-screen parts if necessary via `ScreenshotController`).
    - **Format**: PNG.
    - **Share**: Passes the image file to the share sheet.
    - **Web Note**: If image sharing fails, auto-download the image or open in new tab.

### Feature 3: The "Victory Card" (Post-Match)
- **Location**: Match Result Screen.
- **Action**: User clicks "Share Result".
- **Behavior**:
    - **Capture**: Generates a stylized card showing: *Player A vs Player B*, *Final Score*, and *App Logo*.
    - **Share**: Shares this image directly to social media apps (IG Stories/WhatsApp).

## 4. Implementation Roadmap

### Phase 1: Foundation
1.  **Utilities**: Create `ShareService` class to abstract platform checks (Mobile vs Web).
2.  **Routing**: Add `/t/:id` route in `GoRouter` that redirects to `/tournaments/:id` to keep links short.
3.  **Web UI**: Create `WebShareModal` widget for the fallback UI.

### Phase 2: Integration
1.  **Invite Flow**: Connect `ShareService` to the Tournament Lobby invite button.
2.  **Bracket Share**: Wrap Bracket View in `Screenshot` widget; implement capture logic.
3.  **Victory Card**: Design the 'Card' widget (can be hidden off-screen or shown in dialog) and implement capture/share.

## 5. Notes & Best Practices
- **Deep Linking**: Ensure the `apple-app-site-association` and `assetlinks.json` are configured for the domain to support Universal Links / App Links.
- **Performance**: Show a formatting/loading indicator ("Generating...") while the screenshot is being processed.
- **Social Formatting**: Use bolding/markdown in text shares where supported (e.g. WhatsApp, Discord).