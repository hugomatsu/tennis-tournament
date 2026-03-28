
## Project Structure & Architecture

### Folder Structure
We will follow a **Feature-First** directory structure. This keeps related code (UI, logic, data) together, making the codebase easier to navigate and scale.

```
lib/
├── main.dart                 # Application entry point
├── app.dart                  # Root App widget (Theme, Routing setup)
├── core/                     # Shared/Global code
│   ├── constants/            # App-wide constants (Firebase paths, strings)
│   ├── theme/                # AppTheme, Colors, TextStyles
│   ├── utils/                # Helper functions (Date formatting, Validators)
│   ├── widgets/              # Reusable generic widgets (Buttons, InputFields)
│   └── providers/            # Global providers (Auth state, User object)
└── features/                 # Feature modules
    ├── auth/                 # Authentication feature
    │   ├── data/             # Repositories & DTOs
    │   ├── presentation/     # Screens & Widgets
    │   └── application/      # Logic/State (Riverpod Providers)
    ├── tournaments/          # Tournament management
    ├── matches/              # Match scheduling & viewing
    └── players/              # Player profile & interactions
```

### Architectural Pattern: Riverpod + Repository Pattern
We will separate concerns using a simplified Clean Architecture approach adapted for Flutter with Riverpod.

1.  **Data Layer (`data/`)**:
    *   **Models**: Data classes (using `freezed` for immutability) that map to Firestore documents.
    *   **Repositories**: Classes that handle direct data fetching/writing to Firestore. They abstract the data source from the rest of the app.
2.  **Application/Logic Layer (`application/`)**:
    *   **Providers**: Riverpod providers that manage state.
    *   **Services**: Pure logic classes if needed (e.g., complex calculations).
    *   *Note*: We will avoid a strict "Domain" layer (UseCases) for this size of project to keep velocity high, unless business logic becomes very complex.
3.  **Presentation Layer (`presentation/`)**:
    *   **Screens**: Full-page widgets.
    *   **Widgets**: Feature-specific smaller widgets.
    *   **Controllers**: Classes extending `AsyncNotifier` or similar to handle UI events and state mutations.

### Naming Conventions
- **Files**: `snake_case.dart` (e.g., `tournament_repository.dart`)
- **Classes**: `PascalCase` (e.g., `TournamentRepository`)
- **Variables/Functions**: `camelCase` (e.g., `getTournamentById`)
- **Constants**: `SCREAMING_SNAKE_CASE` (e.g., `MAX_PLAYERS`)