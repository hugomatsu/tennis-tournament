---
description: Theming skill - enforces Material 3 theme system for consistent visual styling
---

# Theming Skill

All visual styling uses the Material 3 theme system for consistency across light/dark modes.

## Theme Structure

```
lib/core/theme/
├── app_theme.dart      # Theme definitions
└── theme_provider.dart # Theme mode state
```

## Theme Configuration

```dart
// core/theme/app_theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  static final lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF6B8E23),
      secondary: Color(0xFF2979FF),
      surface: Colors.white,
      onPrimary: Colors.white,
    ),
    // ... card, text, appBar themes
  );

  static final darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFFCCFF00),
      secondary: Color(0xFF2979FF),
      surface: Color(0xFF1E1E1E),
      onPrimary: Colors.black,
    ),
    // ... card, text, appBar themes
  );
}
```

## Rules

### MUST DO
1. Use `Theme.of(context)` for all colors and text styles
2. Use semantic color names from ColorScheme
3. Define theme in `core/theme/app_theme.dart`
4. Support both light and dark modes
5. Use Material 3 (`useMaterial3: true`)

### MUST NOT
- Hardcode color values in widgets
- Ignore dark mode compatibility
- Create one-off TextStyles inline
- Use deprecated ThemeData properties

## Accessing Theme

```dart
// Colors
Theme.of(context).colorScheme.primary
Theme.of(context).colorScheme.surface
Theme.of(context).colorScheme.onPrimary
Theme.of(context).colorScheme.surfaceContainerHighest

// Text Styles
Theme.of(context).textTheme.displayLarge
Theme.of(context).textTheme.titleMedium
Theme.of(context).textTheme.bodyLarge

// Other
Theme.of(context).dividerColor
Theme.of(context).cardTheme
```

## Common Semantic Colors

| Use Case | Property |
|----------|----------|
| Primary brand color | `colorScheme.primary` |
| Accent/secondary | `colorScheme.secondary` |
| Background | `colorScheme.surface` |
| Card/container | `colorScheme.surfaceContainerHighest` |
| Text on primary | `colorScheme.onPrimary` |
| Text on surface | `colorScheme.onSurface` |
| Error state | `colorScheme.error` |
| Dividers | `dividerColor` |

## Dynamic Opacity (Correct Pattern)

```dart
// DO: Use withValues for Material 3
Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)

// DON'T: withOpacity is deprecated
Theme.of(context).colorScheme.primary.withOpacity(0.1)  // ❌
```

## Theme Mode Provider

```dart
// core/theme/theme_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);
```

## App Configuration

```dart
// app.dart
MaterialApp.router(
  theme: AppTheme.lightTheme,
  darkTheme: AppTheme.darkTheme,
  themeMode: ref.watch(themeModeProvider),
  // ...
)
```
