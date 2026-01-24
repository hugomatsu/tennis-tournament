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
      following: [],
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
        following: [],
      ),
    );
  }

  @override
  Future<List<Player>> getAllPlayers() async {
     await Future.delayed(const Duration(milliseconds: 500));
     return List.generate(
      10,
      (index) => Player(
        id: 'mock_user_$index',
        name: 'User ${index + 1}',
        title: 'Ranking $index',
        category: 'A',
        playingSince: '2023',
        wins: index * 2,
        losses: index,
        rank: index + 1,
        bio: 'Bio',
        avatarUrl: 'https://via.placeholder.com/150',
        userType: 'player',
        followedMatchIds: [],
        following: [],
      ),
    );
  }

  @override
  Future<void> followPlayer(String currentUserId, String targetUserId) async {
    await Future.delayed(const Duration(milliseconds: 200));
  }

  @override
  Future<void> unfollowPlayer(String currentUserId, String targetUserId) async {
    await Future.delayed(const Duration(milliseconds: 200));
  }

  @override
  Future<void> setPremiumStatus(String userId, bool isPremium) async {
    // No-op for mock, or could update a local list if needed
  }

  @override
  Future<void> cancelSubscription(String userId) async {
    // No-op
  }

  @override
  Future<List<Player>> getPlayersByIds(List<String> ids) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Return dummy players for the requested IDs
    return ids.map((id) => Player(
      id: id,
      name: 'User $id',
      title: 'Member',
      category: 'B',
      playingSince: '2024',
      wins: 0,
      losses: 0,
      rank: 0,
      bio: 'Mock Bio',
      avatarUrl: 'https://via.placeholder.com/150',
      userType: 'player',
      followedMatchIds: [],
      following: [],
    )).toList();
  }
  @override
  Future<Player?> getPlayer(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return Player(
      id: id,
      name: 'User $id',
      title: 'Member',
      category: 'B',
      playingSince: '2024',
      wins: 5,
      losses: 2,
      rank: 10,
      bio: 'Mock Bio',
      avatarUrl: 'https://via.placeholder.com/150',
      userType: 'player',
      followedMatchIds: [],
      following: [],
    );
  }

  @override
  Future<int> getTournamentsParticipatedCount(String userId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return 3; // Mock value
  }
}
