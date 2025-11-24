import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tennis_tournament/core/config/feature_flags.dart';
import 'package:tennis_tournament/features/tournaments/data/firestore_tournament_repository.dart';
import 'package:tennis_tournament/features/tournaments/data/mock_tournament_repository.dart';
import 'package:tennis_tournament/features/tournaments/domain/tournament.dart';

final tournamentRepositoryProvider = Provider<TournamentRepository>((ref) {
  if (FeatureFlags.enableMockUi) {
    return MockTournamentRepository();
  } else {
    return FirestoreTournamentRepository();
  }
});

abstract class TournamentRepository {
  Future<List<Tournament>> getLiveTournaments();
  Future<Tournament?> getTournament(String id);
}
