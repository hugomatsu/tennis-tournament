import 'package:tennis_tournament/features/matches/domain/match.dart';
import 'package:tennis_tournament/features/tournaments/domain/participant.dart';
import 'package:tennis_tournament/features/tournaments/domain/tournament.dart';
import 'package:tennis_tournament/features/tournaments/domain/tournament_category.dart';

abstract class SchedulingService {
  Future<List<TennisMatch>> generateBracket(
    Tournament tournament,
    TournamentCategory category,
    List<Participant> participants, {
    bool shuffle = true,
  });
}
