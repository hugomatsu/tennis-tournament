# Entre Sets — Claude Rules

## Localization

**Every screen and widget** that displays user-facing text **MUST** use `AppLocalizations`. No hardcoded UI strings allowed. **Portuguese-BR (`pt_BR`) is always the default locale.**

### Getting the loc instance (mandatory in every screen)
```dart
final loc = AppLocalizations.of(context)!;
```

### Adding new strings
1. Add the key to `lib/l10n/app_pt.arb` first (source of truth — pt_BR is default)
2. Mirror the key in `lib/l10n/app_en.arb` with the English equivalent
3. Run `flutter gen-l10n` to regenerate `app_localizations.dart`

### Strings with parameters
Use ARB placeholders — never string interpolation for sentences:
```json
"welcomeUser": "Olá, {name}!",
"@welcomeUser": { "placeholders": { "name": { "type": "String" } } }
```

### Dates & numbers
Always pass the current locale — never hardcode formats:
```dart
final locale = Localizations.localeOf(context).toString();
DateFormat.yMMMd(locale).format(date)
NumberFormat.decimalPattern(locale).format(number)
```

### Forbidden
- `Text('Any hardcoded string')`
- `SnackBar(content: Text('Error occurred'))`
- `'${date.day}/${date.month}/${date.year}'`
- Adding a key only to `app_en.arb` without `app_pt.arb`

### Reference
- ARB files: `lib/l10n/`
- Generated class: `lib/l10n/app_localizations.dart`
- l10n config: `l10n.yaml`

---

## Share Feature

When implementing or modifying any feature that involves sharing (tournaments, brackets, matches, groups), **ALWAYS** use the unified `SharePreviewScreen`. **NEVER** implement direct native sharing (`SharePlus.share()`) or custom share dialogs.

### Implementation
1. **Entry Point**: Call `SharePreviewScreen.show(context: context, shareWidget: widget, shareSubject: subject)`.
2. **Sharing Service**: Use `SharingService` (via `sharingServiceProvider`) for screenshot capture, clipboard, download, and native share sheet operations.
3. **Deep Links**: Tournament links use dynamic links that open the tournament detail screen in-app or redirect to the store if not installed.

### UI/UX: Preview-First Pattern
1. User taps "Share" icon/button.
2. App displays the `SharePreviewScreen` modal with:
   - **Preview**: The share widget rendered with a selectable background color (blue, red, yellow, none, custom)
   - **Actions**: Copy to Clipboard, Download Image, Share via native sheet (captures as PNG)

### Forbidden
- Calling `SharePlus.share()` directly from any screen
- Sharing only a text link without the visual preview card
- Creating custom share designs outside `SharePreviewScreen`

### Reference
- Widget: `lib/core/sharing/widgets/share_preview_screen.dart`
- Service: `lib/core/sharing/sharing_service.dart`
- Button: `lib/core/sharing/widgets/share_button.dart`

---

## Architecture & State Management

- **State Management**: Flutter Riverpod with `riverpod_annotation` and code generation
- **Models**: Freezed for immutable domain models with JSON serialization
- **Routing**: GoRouter with `StatefulShellRoute` for bottom navigation (3 tabs: Tournaments, Schedule, Profile)
- **Backend**: Firebase (Firestore, Auth, Storage, Messaging, Crashlytics, Analytics)
- **Code Generation**: Run `dart run build_runner build --delete-conflicting-outputs` after modifying Freezed models or Riverpod providers

---

## Tournament Modes

The app supports three tournament modes via `tournament.tournamentType`:

- **`mataMata`** — Single elimination bracket. Lose once and you're out.
- **`openTennis`** — Round-robin group stage + playoff bracket. Players play all others in their group, top players advance to a single-elimination playoff.
- **`americano`** — Cross-group rounds + group decider + bracket. Players are divided into groups but only play opponents from other groups (guaranteed N matches each). Top 2 per group play a decider match; winners advance to a single-elimination playoff.

When working on bracket/match features, always consider all three modes.
