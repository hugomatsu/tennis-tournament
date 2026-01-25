---
description: Riverpod state management - enforces consistent provider patterns for state and async data
---

# Riverpod State Management Skill

Consistent patterns for Riverpod providers and state management.

## Provider Types & Usage

| Type | Use Case | Example |
|------|----------|---------|
| `FutureProvider` | Async data fetch | User profile, tournament details |
| `FutureProvider.family` | Async with params | Get player by ID |
| `StreamProvider` | Real-time data | Match updates, chat |
| `Provider` | Services, controllers | Repository, SharingService |
| `StateProvider` | Simple mutable state | Toggle, counter |

## Patterns

### Data Fetching
```dart
// Simple async data
final currentUserProvider = FutureProvider<User?>((ref) {
  return ref.watch(userRepositoryProvider).getCurrentUser();
});

// With dependency on auth state
final currentUserProvider = FutureProvider<User?>((ref) {
  ref.watch(authStateChangesProvider); // Invalidate when auth changes
  return ref.watch(userRepositoryProvider).getCurrentUser();
});
```

### Parameterized Provider
```dart
// With parameter (family)
final playerProvider = FutureProvider.family<Player, String>((ref, id) async {
  if (id.isEmpty) throw Exception('Player ID cannot be empty');
  final player = await ref.watch(playerRepositoryProvider).getPlayer(id);
  if (player == null) throw Exception('Player not found');
  return player;
});
```

### Controller Pattern
```dart
// Provider for controller
final playerControllerProvider = Provider((ref) => PlayerController(ref));

class PlayerController {
  final Ref _ref;
  PlayerController(this._ref);

  Future<void> followUser(String targetUserId) async {
    final currentUser = await _ref.read(currentUserProvider.future);
    if (currentUser == null) return;
    
    await _ref.read(playerRepositoryProvider).followPlayer(
      currentUser.id, 
      targetUserId
    );
    
    // Always invalidate after mutation
    _ref.invalidate(currentUserProvider);
  }
}
```

### Service Provider
```dart
final sharingServiceProvider = Provider((ref) => SharingService());
```

## Rules

### MUST DO
1. Providers go in `application/{feature}_providers.dart`
2. Use `ref.watch()` in providers for dependencies
3. Use `ref.read()` in methods for one-time access
4. Invalidate providers after mutations: `ref.invalidate(providerName)`
5. Handle errors in FutureProvider consumers

### MUST NOT
- Use StateNotifier when FutureProvider suffices
- Forget to invalidate after data mutations
- Call `.future` in synchronous widget builds
- Create providers inside widgets

## Consuming in Widgets

```dart
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncValue = ref.watch(playerProvider(playerId));
    
    return asyncValue.when(
      data: (player) => PlayerCard(player: player),
      loading: () => const CircularProgressIndicator(),
      error: (e, _) => Text('Error: $e'),
    );
  }
}
```

## Refresh Pattern

```dart
// In widget - pull to refresh
RefreshIndicator(
  onRefresh: () => ref.refresh(tournamentsProvider.future),
  child: ListView(...),
)

// In controller - after mutation
_ref.invalidate(tournamentsProvider);
```
