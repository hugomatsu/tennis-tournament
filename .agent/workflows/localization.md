---
description: Localization & Internationalization Guide - ensures all strings, dates, and formats are locale-aware for global shipping
---

# Localization & Internationalization Guide

This skill ensures all user-facing content is properly internationalized, enabling seamless global deployment without refactoring.

## Core Principles

1. **No hardcoded user-facing strings** - Every visible string must use localization
2. **Locale-aware formatting** - Dates, times, numbers, and currencies must respect locale
3. **RTL support consideration** - Layout should be adaptable for right-to-left languages

---

## Flutter Localization Setup

### Required Dependencies
```yaml
# pubspec.yaml
dependencies:
  flutter_localizations:
    sdk: flutter
  intl: any

flutter:
  generate: true
```

### Configuration File
```yaml
# l10n.yaml
arb-dir: lib/l10n
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
```

### App Configuration
```dart
// In MaterialApp or CupertinoApp
MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  // ...
)
```

---

## String Localization Rules

### ✅ DO: Use localized strings
```dart
// Good - uses localization
Text(AppLocalizations.of(context)!.welcomeMessage)

// Good - with parameters
Text(loc.itemCount(items.length))  // "You have {count} items"

// Good - pluralization
Text(loc.daysRemaining(days))  // "1 day" vs "5 days"
```

### ❌ DON'T: Hardcode user-facing strings
```dart
// Bad - hardcoded
Text('Welcome!')
Text('You have $count items')
SnackBar(content: Text('Error occurred'))
```

### ARB File Format
```json
{
  "@@locale": "en",
  "welcomeMessage": "Welcome!",
  "itemCount": "{count} items",
  "@itemCount": {
    "placeholders": {
      "count": {"type": "int"}
    }
  },
  "daysRemaining": "{count, plural, =1{1 day remaining} other{{count} days remaining}}",
  "@daysRemaining": {
    "placeholders": {
      "count": {"type": "int"}
    }
  }
}
```

---

## Date & Time Formatting

### ✅ DO: Use intl package with locale
```dart
import 'package:intl/intl.dart';

// Good - locale-aware date formatting
final locale = Localizations.localeOf(context).toString();
DateFormat.yMMMd(locale).format(date)  // "Jan 25, 2026" or "25 jan. 2026"

// Good - relative time
DateFormat.jm(locale).format(time)  // "5:30 PM" or "17:30"

// Good - weekday
DateFormat.EEEE(locale).format(date)  // "Saturday" or "sábado"
```

### ❌ DON'T: Use hardcoded date formats
```dart
// Bad - fixed format ignores locale
'${date.month}/${date.day}/${date.year}'
DateFormat('MM/dd/yyyy').format(date)
```

### Common DateFormat Patterns
| Pattern | Example (en_US) | Example (pt_BR) |
|---------|-----------------|-----------------|
| `yMd()` | 1/25/2026 | 25/01/2026 |
| `yMMMd()` | Jan 25, 2026 | 25 de jan. de 2026 |
| `yMMMMd()` | January 25, 2026 | 25 de janeiro de 2026 |
| `jm()` | 5:30 PM | 17:30 |
| `EEEE()` | Saturday | sábado |

---

## Number & Currency Formatting

### ✅ DO: Use NumberFormat with locale
```dart
import 'package:intl/intl.dart';

final locale = Localizations.localeOf(context).toString();

// Good - number formatting
NumberFormat.decimalPattern(locale).format(1234.56)
// en_US: "1,234.56" | de_DE: "1.234,56" | pt_BR: "1.234,56"

// Good - currency
NumberFormat.currency(locale: locale, symbol: 'R\$').format(99.99)
// pt_BR: "R$ 99,99"

// Good - percentage
NumberFormat.percentPattern(locale).format(0.85)
// en_US: "85%" | fr_FR: "85 %"

// Good - compact numbers
NumberFormat.compact(locale: locale).format(1500000)
// en_US: "1.5M" | pt_BR: "1,5 mi"
```

### ❌ DON'T: Format numbers manually
```dart
// Bad - ignores locale decimal/grouping separators
'\$${price.toStringAsFixed(2)}'
'${number.toString().replaceAllMapped(...)}'
```

---

## Best Practices Checklist

### Before Every PR
- [ ] All user-facing strings use `AppLocalizations`
- [ ] All dates use `DateFormat` with locale parameter
- [ ] All numbers/currencies use `NumberFormat` with locale
- [ ] New strings added to **all** ARB files (with translations pending)
- [ ] No string concatenation for sentences (use placeholders)
- [ ] Pluralization handled correctly for countable items

### ARB File Maintenance
- [ ] Template file (app_en.arb) is the source of truth
- [ ] Keys are descriptive and follow camelCase
- [ ] Complex strings have `@key` descriptions
- [ ] Run `flutter gen-l10n` after ARB changes

### Testing
```dart
// Test different locales
testWidgets('shows localized date', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('pt', 'BR'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: MyWidget(),
    ),
  );
  expect(find.text('25 de jan. de 2026'), findsOneWidget);
});
```

---

## Quick Reference: Getting Locale

```dart
// Get current locale
final locale = Localizations.localeOf(context);
final localeString = locale.toString();  // "en_US" or "pt_BR"

// Get localization instance (common shorthand)
final loc = AppLocalizations.of(context)!;

// Check locale for conditional logic
if (locale.languageCode == 'pt') {
  // Portuguese-specific behavior
}
```

---

## Adding New Languages

1. Create new ARB file: `lib/l10n/app_XX.arb` (e.g., `app_es.arb`)
2. Copy content from `app_en.arb`
3. Translate all values (keep keys unchanged)
4. Run `flutter gen-l10n`
5. Add locale to `supportedLocales` if not auto-detected
