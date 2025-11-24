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
  Future<List<TennisMatch>> getLiveTournamentsMatches() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [];
  }

  @override
  Future<List<TennisMatch>> getMatchesForTournament(String tournamentId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [];
  }

  @override
  Future<List<TennisMatch>> getUpcomingMatches() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [];
  }

  @override
  Future<void> createMatches(List<TennisMatch> matches) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Mock implementation: do nothing
  }
}
