---
description: Repository pattern - abstracts data access with consistent Firestore patterns
---

# Repository Pattern Skill

Abstracts all data access behind repository interfaces with Firestore implementation.

## Structure

```
lib/features/{feature}/data/
├── {name}_repository.dart           # Abstract interface
└── firestore_{name}_repository.dart # Firestore implementation
```

## Interface Template

```dart
// Abstract repository interface
abstract class PlayerRepository {
  Future<Player?> getPlayer(String id);
  Future<List<Player>> getAllPlayers();
  Future<void> createPlayer(Player player);
  Future<void> updatePlayer(Player player);
  Future<void> deletePlayer(String id);
  Stream<Player?> watchPlayer(String id);
}
```

## Firestore Implementation Template

```dart
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestorePlayerRepository implements PlayerRepository {
  final _collection = FirebaseFirestore.instance.collection('players');

  @override
  Future<Player?> getPlayer(String id) async {
    final doc = await _collection.doc(id).get();
    if (!doc.exists || doc.data() == null) return null;
    return _fromData(doc.id, doc.data()!);
  }

  @override
  Future<List<Player>> getAllPlayers() async {
    final snapshot = await _collection.get();
    return snapshot.docs
        .map((doc) => _fromData(doc.id, doc.data()))
        .toList();
  }

  @override
  Future<void> createPlayer(Player player) async {
    await _collection.doc(player.id).set(_toData(player));
  }

  @override
  Future<void> updatePlayer(Player player) async {
    await _collection.doc(player.id).update(_toData(player));
  }

  @override
  Future<void> deletePlayer(String id) async {
    await _collection.doc(id).delete();
  }

  @override
  Stream<Player?> watchPlayer(String id) {
    return _collection.doc(id).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return _fromData(doc.id, doc.data()!);
    });
  }

  // Private helpers
  Player _fromData(String id, Map<String, dynamic> data) {
    return Player(
      id: id,
      name: data['name'] ?? '',
      // ... other fields
    );
  }

  Map<String, dynamic> _toData(Player player) {
    return {
      'name': player.name,
      // ... other fields (don't include 'id')
    };
  }
}
```

## Provider Setup

```dart
// In application/{feature}_providers.dart or data/{feature}_repository.dart
final playerRepositoryProvider = Provider<PlayerRepository>((ref) {
  return FirestorePlayerRepository();
});
```

## Rules

### MUST DO
1. Create abstract interface for repository
2. Place implementation in `firestore_{name}_repository.dart`
3. Convert Firestore data to domain models immediately
4. Use private `_fromData` and `_toData` helpers
5. Use batch writes for multiple operations
6. Expose via Provider

### MUST NOT
- Access Firestore directly from widgets
- Return DocumentSnapshot to UI layer
- Put repository logic in presentation layer
- Hardcode collection names in multiple places

## Firestore Patterns

### Batch Operations
```dart
Future<void> createMatches(List<TennisMatch> matches) async {
  final batch = FirebaseFirestore.instance.batch();
  for (final match in matches) {
    final docRef = _collection.doc(match.id);
    batch.set(docRef, _toData(match));
  }
  await batch.commit();
}
```

### Real-time Streams
```dart
Stream<List<Tournament>> watchLiveTournaments() {
  return _collection
      .where('status', isEqualTo: 'Live Now')
      .snapshots()
      .map((snap) => snap.docs
          .map((doc) => _fromData(doc.id, doc.data()))
          .toList());
}
```

### Subcollections
```dart
Future<List<Category>> getCategories(String tournamentId) async {
  final snapshot = await _tournamentCollection
      .doc(tournamentId)
      .collection('categories')
      .get();
  return snapshot.docs.map((doc) => _categoryFromData(doc.id, doc.data())).toList();
}
```
