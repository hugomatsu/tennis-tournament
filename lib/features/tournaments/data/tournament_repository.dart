import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tennis_tournament/core/config/feature_flags.dart';
import 'package:tennis_tournament/features/tournaments/data/firestore_tournament_repository.dart';
import 'package:tennis_tournament/features/tournaments/data/mock_tournament_repository.dart';
import 'package:tennis_tournament/features/tournaments/domain/participant.dart';
import 'package:tennis_tournament/features/tournaments/domain/tournament.dart';

final tournamentRepositoryProvider = Provider<TournamentRepository>((ref) {
  if (FeatureFlags.enableMockUi) {
    return MockTournamentRepository();
  } else {
    return FirestoreTournamentRepository();
  }
});

abstract class TournamentRepository {
  Future<List<Tournament>> getLiveTournaments({String? category});
  Future<Tournament?> getTournament(String id);
  Future<void> createTournament(Tournament tournament);
  Future<void> joinTournament(String tournamentId, String userId);
  Future<bool> isPlayerRegistered(String tournamentId, String userId);
  
  // Participant Management
  Future<List<Participant>> getParticipants(String tournamentId);
  Future<Participant?> getParticipant(String tournamentId, String userId);
  Future<void> addParticipant(String tournamentId, Participant participant);
  Future<void> updateParticipantStatus(String tournamentId, String participantId, String status);
}
