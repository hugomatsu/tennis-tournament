import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tennis_tournament/features/auth/data/auth_repository.dart';
import 'package:tennis_tournament/features/players/data/player_repository.dart';
import 'package:tennis_tournament/features/players/domain/player.dart';

final currentUserProvider = FutureProvider<Player?>((ref) {
  // Invalidate provider when auth state changes to force refresh
  ref.watch(authStateChangesProvider);
  return ref.watch(playerRepositoryProvider).getCurrentUser();
});

final allPlayersProvider = FutureProvider<List<Player>>((ref) {
  return ref.watch(playerRepositoryProvider).getAllPlayers();
});

final friendsProvider = FutureProvider<List<Player>>((ref) async {
  final user = await ref.watch(currentUserProvider.future);
  if (user == null || user.following.isEmpty) return [];
  
  // Naive implementation: fetch all players and filter.
  // Ideally, use a query 'whereIn' (chunks of 10) or 'getUsers(ids)'
  final allPlayers = await ref.watch(allPlayersProvider.future);
  return allPlayers.where((p) => user.following.contains(p.id)).toList();
});

final playerProvider = FutureProvider.family<Player, String>((ref, id) async {
  if (id.isEmpty) throw Exception('Player ID cannot be empty');
  final player = await ref.watch(playerRepositoryProvider).getPlayer(id);
  if (player == null) throw Exception('Player not found');
  return player;
});

final playerControllerProvider = Provider((ref) => PlayerController(ref));

class PlayerController {
  final Ref _ref;
  PlayerController(this._ref);

  Future<void> followUser(String targetUserId) async {
     final currentUser = await _ref.read(currentUserProvider.future);
     if (currentUser == null) return;
     
     await _ref.read(playerRepositoryProvider).followPlayer(currentUser.id, targetUserId);
     _ref.invalidate(currentUserProvider); // Refresh to update 'following' list
  }

  Future<void> unfollowUser(String targetUserId) async {
     final currentUser = await _ref.read(currentUserProvider.future);
     if (currentUser == null) return;
     
     await _ref.read(playerRepositoryProvider).unfollowPlayer(currentUser.id, targetUserId);
     _ref.invalidate(currentUserProvider);
  }
}
