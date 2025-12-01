import 'package:tennis_tournament/core/utils/mock_data.dart';
import 'package:tennis_tournament/features/matches/data/match_repository.dart';
import 'package:tennis_tournament/features/matches/domain/match.dart';

class MockMatchRepository implements MatchRepository {
  @override
  Future<TennisMatch?> getNextMatch() async {
    await Future.delayed(const Duration(milliseconds: 500));
    final data = MockData.nextMatch;
      return TennisMatch(
        id: data['id'] as String,
        tournamentId: data['tournamentId'] as String,
        categoryId: 'mock_category',
        tournamentName: data['tournamentName'] as String,
        player1Id: 'mock_p1',
        player1Name: data['opponentName'] as String,
        player1AvatarUrl: 'https://i.pravatar.cc/150?u=mock_p1',
        player2Id: 'mock_p2',
        player2Name: 'Opponent',
        player2AvatarUrl: 'https://i.pravatar.cc/150?u=mock_p2',
        opponentName: data['opponentName'] as String,
        time: DateTime.parse(data['time'] as String),
        court: data['court'] as String,
        round: data['round'] as String,
        status: data['status'] as String,
        score: data['score'] as String?,
        winner: data['winner'] as String?,
        matchIndex: 0,
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
  Stream<List<TennisMatch>> watchMatchesForTournament(String tournamentId) {
    return Stream.value([]);
  }

  @override
  Stream<List<TennisMatch>> watchUpcomingMatches() {
    return Stream.value([]);
  }

  @override
  Future<void> cheerForMatch(String matchId, String playerId) async {
    // Mock implementation
    await Future.delayed(const Duration(milliseconds: 200));
  }

  @override
  Future<void> confirmMatch(String matchId, String playerId) async {
    // Mock implementation
    await Future.delayed(const Duration(milliseconds: 200));
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

  @override
  Future<void> updateMatch(TennisMatch match) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<void> updateMatchScore(String matchId, String score, String winnerName) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }
}
