import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tennis_tournament/core/config/feature_flags.dart';
import 'package:tennis_tournament/features/matches/data/firestore_match_repository.dart';
import 'package:tennis_tournament/features/matches/data/mock_match_repository.dart';
import 'package:tennis_tournament/features/matches/domain/match.dart';

final matchRepositoryProvider = Provider<MatchRepository>((ref) {
  if (FeatureFlags.enableMockUi) {
    return MockMatchRepository();
  } else {
    return FirestoreMatchRepository();
  }
});

final matchesForTournamentProvider = FutureProvider.family<List<TennisMatch>, String>((ref, tournamentId) {
  return ref.watch(matchRepositoryProvider).getMatchesForTournament(tournamentId);
});

abstract class MatchRepository {
  Future<TennisMatch?> getNextMatch();
  Future<List<TennisMatch>> getLiveTournamentsMatches();
  Future<List<TennisMatch>> getMatchesForTournament(String tournamentId);
  Stream<List<TennisMatch>> watchMatchesForTournament(String tournamentId);
  Future<List<TennisMatch>> getUpcomingMatches();
  Stream<List<TennisMatch>> watchUpcomingMatches(List<String> followedMatchIds);
  Future<void> createMatches(List<TennisMatch> matches);
  Future<void> updateMatch(TennisMatch match);
  Future<void> updateMatchScore(String matchId, String score, String winnerName, {String resultType = 'normal'});
  Future<void> cheerForMatch(String matchId, String playerId);
  Future<void> confirmMatch(String matchId, String playerId);
  Future<void> deleteMatchesForTournament(String tournamentId);
  Future<TennisMatch?> getMatch(String matchId);
  Future<List<TennisMatch>> getMatchesByIds(List<String> matchIds);

  Stream<TennisMatch?> watchMatch(String matchId);
  Future<void> updateMatchesStatus(List<String> matchIds, String status);
}
