import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tennis_tournament/core/config/feature_flags.dart';
import 'package:tennis_tournament/features/players/data/firestore_player_repository.dart';
import 'package:tennis_tournament/features/players/data/mock_player_repository.dart';
import 'package:tennis_tournament/features/players/domain/player.dart';

final playerRepositoryProvider = Provider<PlayerRepository>((ref) {
  if (FeatureFlags.enableMockUi) {
    return MockPlayerRepository();
  } else {
    return FirestorePlayerRepository();
  }
});

abstract class PlayerRepository {
  Future<Player?> getCurrentUser();
  Future<void> updateUser(Player player);
  Future<List<Player>> getPlayersForTournament(String tournamentId);
  Future<List<Player>> getAllPlayers();
  Future<void> followPlayer(String currentUserId, String targetUserId);
  Future<void> unfollowPlayer(String currentUserId, String targetUserId);
}
