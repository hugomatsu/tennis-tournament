import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tennis_tournament/features/tournaments/data/tournament_repository.dart';
import 'package:tennis_tournament/features/tournaments/domain/participant.dart';
import 'package:tennis_tournament/features/tournaments/domain/tournament_category.dart';

final participantsProvider = FutureProvider.family<List<Participant>, String>((ref, tournamentId) {
  return ref.watch(tournamentRepositoryProvider).getParticipants(tournamentId);
});

final tournamentCategoriesProvider = FutureProvider.family<List<TournamentCategory>, String>((ref, tournamentId) {
  return ref.watch(tournamentRepositoryProvider).getCategories(tournamentId);
});
