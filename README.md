# Entre Sets — Onde o torneio também vira resenha

A premium, cross-platform (Mobile & Web) application built with Flutter to manage tennis tournaments, schedule matches, and track player stats with a modern, high-fidelity design.

## Features

*   **Tournament Management**: Create and manage single-elimination tournaments.
*   **Bracket Generation**: Automated scheduling with optional manual reordering and specific constraints.
*   **Match Control**: Real-time match status, scoring, and admin controls for attendance and rescheduling.
*   **Player Profiles**: Rich profiles with stats, bios, and customizable avatars.
*   **Social**: "Cheer" for players in real-time.
*   **Interactive Locations**: Google Maps integration for court locations.

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
