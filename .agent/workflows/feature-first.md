---
description: Feature-first architecture - enforces feature-based folder organization with strict layer separation
---

# Feature-First Architecture Skill

This skill ensures every feature follows a consistent folder structure with proper layer separation.

## Structure

```
lib/features/{feature_name}/
├── domain/           # Models, entities, value objects
├── data/             # Repositories, data sources
├── application/      # Providers, controllers, services (optional)
└── presentation/     # Screens, widgets, pages
```

## Rules

### MUST DO
1. Create feature folder at `lib/features/{feature_name}/`
2. Create `domain/` subdirectory for all models
3. Create `data/` subdirectory for repositories
4. Create `presentation/` subdirectory for UI
5. Optionally create `application/` for providers/controllers if complex

### MUST NOT
- Create flat file structures in `lib/`
- Mix data layer logic with presentation widgets
- Import sibling feature internals (use core for shared)
- Put screens directly in `lib/` or `lib/screens/`

## File Naming

| Type | Pattern | Example |
|------|---------|---------|
| Domain model | `{name}.dart` | `tournament.dart` |
| Repository interface | `{name}_repository.dart` | `tournament_repository.dart` |
| Firestore repo | `firestore_{name}_repository.dart` | `firestore_tournament_repository.dart` |
| Providers | `{name}_providers.dart` | `tournament_providers.dart` |
| Screen | `{name}_screen.dart` | `tournament_detail_screen.dart` |
| Widgets folder | `widgets/` | `presentation/widgets/` |

## Example: Creating "notifications" Feature

```
lib/features/notifications/
├── domain/
│   └── notification.dart
├── data/
│   ├── notification_repository.dart
│   └── firestore_notification_repository.dart
├── application/
│   └── notification_providers.dart
└── presentation/
    ├── notifications_screen.dart
    └── widgets/
        └── notification_tile.dart
```

## Quick Check

Before completing, verify:
- [ ] Feature folder exists at correct path
- [ ] Domain models in `domain/`
- [ ] Repository in `data/`
- [ ] Screens in `presentation/`
- [ ] No circular imports between features
