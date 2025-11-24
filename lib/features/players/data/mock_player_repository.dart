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
    );
  }
}
