import 'package:tennis_tournament/core/utils/mock_data.dart';
import 'package:tennis_tournament/features/matches/data/match_repository.dart';
import 'package:tennis_tournament/features/matches/domain/match.dart';

class MockMatchRepository implements MatchRepository {
  @override
  Future<TennisMatch?> getNextMatch() async {
    await Future.delayed(const Duration(milliseconds: 500));
    final data = MockData.nextMatch;
    return TennisMatch(
      id: 'mock_next_match',
      tournamentId: 'mock_t_1',
      tournamentName: data['tournament']!,
      opponentName: data['opponent']!,
      time: DateTime.now().add(const Duration(days: 1)), // Approximate "Tomorrow"
      court: data['court']!,
      round: data['round']!,
      status: 'Scheduled',
    );
  }

  @override
  Future<List<TennisMatch>> getMySchedule() async {
    await Future.delayed(const Duration(milliseconds: 500));
    final List<TennisMatch> matches = [];
    
    for (var day in MockData.mySchedule) {
      final dayMatches = day['matches'] as List;
      for (var m in dayMatches) {
        matches.add(TennisMatch(
          id: 'mock_schedule_${matches.length}',
          tournamentId: 'mock_t_${matches.length}',
          tournamentName: m['tournament'],
          opponentName: m['opponent'],
          time: DateTime.now(), // Simplified for mock
          court: m['court'],
          round: 'Group Stage',
          status: m['status'],
        ));
      }
    }
    return matches;
  }

  @override
  Future<List<Map<String, dynamic>>> getBracket(String tournamentId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return MockData.bracket;
  }
}
