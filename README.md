# Entre Sets — Onde o torneio também vira resenha

A premium, cross-platform (Mobile & Web) application built with Flutter to manage tennis tournaments, schedule matches, and track player stats with a modern, high-fidelity design.

## Features & Implementation Status

### Core Features
*   **Tournament Management**: Create and manage single-elimination tournaments with recurring schedules (dates and times) and Markdown-supported descriptions.
*   **Bracket Generation**: Automated scheduling engine with constraint satisfaction based on player availability and court slots.
*   **Match Control**: Real-time match status, scoring, and admin controls for attendance and rescheduling.
*   **Player Profiles**: Rich profiles with stats, bios, customizable avatars, and preferences.
*   **Social**: "Cheer" for players in real-time, share tournament details.
*   **Interactive Locations**: Google Maps integration for court locations.
*   **Notifications**: Push notifications via FCM, in-app notification center, deep linking to matches/tournaments, and profile notification settings.

### Tech Stack & Architecture
*   **Framework**: Flutter (SDK 3.10+)
*   **Backend**: Firebase (Auth, Firestore, Storage, Cloud Functions, Messaging)
*   **Architecture**: Feature-first folder organization (`lib/features/`).
*   **State Management**: Riverpod (`riverpod_annotation`, `riverpod_generator`).
*   **Data Models**: Freezed (`freezed_annotation`) with JSON serialization.
*   **Navigation**: GoRouter with type-safe routing.

## AI Kickstart Guide

**For future AI Agents working on this project:**
1.  **Workflows**: The user has established specific workflows that MUST be followed. Always rely on the user's provided context for rules on:
    *   `/feature-first`: Feature-based folder organization with strict layer separation.
    *   `/riverpod-state`: Riverpod state management patterns.
    *   `/repository-pattern`: Repository pattern for Firestore data access.
    *   `/freezed-models`: Immutable domain models.
    *   `/navigation`: GoRouter navigation with `StatefulShellRoute`.
    *   `/theming`: Material 3 theme system for consistent styling.
    *   `/localization`: Locale-aware strings and formatting.
2.  **Recent Implementations**:
    *   **Tournaments**: Added recurring schedule support, markdown descriptions, and premium user gating logic.
    *   **Notifications**: Comprehensive system built using FCM, including deep linking and profile toggles.
    *   **Cloud Functions**: Deployed for push notifications and dynamic tasks.
3.  **State & Models**: Always use `freezed` for models and `riverpod_generator` for providers. Run `flutter pub run build_runner build -d` after modifying these files.

## Getting Started

### Prerequisites
- Flutter SDK (3.10+)
- Dart SDK
- Firebase Project

### Installation
1.  Clone the repository.
2.  Create a `.env` file in the root directory with your Firebase configuration.
3.  Install dependencies:
    ```bash
    flutter pub get
    ```

## Running the App

To run the app on Chrome (Web), ensure you specify the web port if needed for auth redirects:
```bash
flutter run -d chrome --web-port 8080
```

## Building

For detailed instructions on configuring signing keys and publishing to stores, see [docs/publish.md](docs/publish.md).

### Android
```bash
flutter build apk --release
# or
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
# Then open ios/Runner.xcworkspace in Xcode and Archive
```

## Testing

This project uses the standard Flutter testing framework.

### Running Unit & Widget Tests
To run all tests in the `test/` directory:
```bash
flutter test
```

### Static Analysis
To check for code quality and linting issues:
```bash
flutter analyze
```

export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/platform-tools
