---
description: Freezed models - enforces immutable domain models with JSON serialization
---

# Freezed Models Skill

Every domain model uses Freezed for immutability, equality, and JSON serialization.

## Required Dependencies

```yaml
# pubspec.yaml
dependencies:
  freezed_annotation: ^2.4.1
  json_annotation: ^4.8.1

dev_dependencies:
  freezed: ^2.4.7
  json_serializable: ^6.7.1
  build_runner: ^2.4.9
```

## Model Template

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part '{filename}.freezed.dart';
part '{filename}.g.dart';

@freezed
abstract class {ModelName} with _${ModelName} {
  const factory {ModelName}({
    required String id,
    required String name,
    @Default('') String description,
    @Default(0) int count,
  }) = _{ModelName};

  factory {ModelName}.fromJson(Map<String, dynamic> json) =>
      _${ModelName}FromJson(json);
}
```

## Rules

### MUST DO
1. Use `@freezed` annotation on all domain models
2. Include both `part` statements (freezed + g.dart)
3. Use `@Default()` for optional fields with defaults
4. Use `required` keyword for mandatory fields
5. Add `fromJson` factory for API/database models
6. Document field purposes with inline comments
7. Run `dart run build_runner build` after changes

### MUST NOT
- Create mutable domain classes
- Use `late` fields in models
- Skip JSON serialization for persisted models
- Use `dynamic` types in model fields
- Forget to regenerate after model changes

## Common Patterns

### Nested Objects
```dart
@freezed
abstract class Tournament with _$Tournament {
  const factory Tournament({
    required String id,
    @Default([]) List<DailySchedule> scheduleRules,
  }) = _Tournament;
  
  factory Tournament.fromJson(Map<String, dynamic> json) =>
      _$TournamentFromJson(json);
}

@freezed
abstract class DailySchedule with _$DailySchedule {
  const factory DailySchedule({
    required String date,
    required String startTime,
  }) = _DailySchedule;
  
  factory DailySchedule.fromJson(Map<String, dynamic> json) =>
      _$DailyScheduleFromJson(json);
}
```

### DateTime Handling
```dart
// Use JsonKey for DateTime conversion
@freezed
abstract class Event with _$Event {
  const factory Event({
    required String id,
    @JsonKey(fromJson: _dateFromTimestamp, toJson: _dateToTimestamp)
    required DateTime createdAt,
  }) = _Event;
  
  factory Event.fromJson(Map<String, dynamic> json) =>
      _$EventFromJson(json);
}

DateTime _dateFromTimestamp(Timestamp ts) => ts.toDate();
Timestamp _dateToTimestamp(DateTime dt) => Timestamp.fromDate(dt);
```

## Build Commands

```bash
# One-time build
dart run build_runner build

# Watch mode (development)
dart run build_runner watch

# Clean and rebuild
dart run build_runner build --delete-conflicting-outputs
```
