import 'package:tennis_tournament/core/utils/mock_data.dart';
import 'package:tennis_tournament/features/players/data/player_repository.dart';
import 'package:tennis_tournament/features/players/domain/player.dart';

class MockPlayerRepository implements PlayerRepository {
  @override
  Future<Player?> getCurrentUser() async {
    await Future.delayed(const Duration(milliseconds: 500));
    final data = MockData.userProfile;
    return Player(
      id: 'mock_user_1',
      name: data['name'] as String,
      title: data['title'] as String,
      category: data['category'] as String,
      playingSince: data['playingSince'] as String,
      wins: data['wins'] as int,
      losses: data['losses'] as int,
      rank: data['rank'] as int,
      bio: data['bio'] as String,
      avatarUrl: data['avatar'] as String,
      followedMatchIds: [],
    );
  }
  @override
  Future<void> updateUser(Player player) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Mock update logic (no-op)
  }
  @override
  Future<List<Player>> getPlayersForTournament(String tournamentId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Return some mock players
    return List.generate(
      8,
      (index) => Player(
        id: 'mock_p_$index',
        name: 'Player ${index + 1}',
        title: 'Pro',
        category: 'A',
        playingSince: '2020',
        wins: 10,
        losses: 2,
        rank: index + 1,
        bio: 'Bio',
        avatarUrl: 'https://via.placeholder.com/150',
        userType: 'player',
        followedMatchIds: [],
      ),
    );
  }
}
