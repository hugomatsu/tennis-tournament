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

abstract class MatchRepository {
  Future<TennisMatch?> getNextMatch();
  Future<List<TennisMatch>> getLiveTournamentsMatches();
  Future<List<TennisMatch>> getMatchesForTournament(String tournamentId);
  Future<List<TennisMatch>> getUpcomingMatches();
  Future<void> createMatches(List<TennisMatch> matches);
}
