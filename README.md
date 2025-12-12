# Tennis Tournament Manager

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
