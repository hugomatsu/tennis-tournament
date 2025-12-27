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
