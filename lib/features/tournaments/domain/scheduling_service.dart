import 'package:tennis_tournament/features/matches/domain/match.dart';
import 'package:tennis_tournament/features/tournaments/domain/participant.dart';
import 'package:tennis_tournament/features/tournaments/domain/tournament.dart';

abstract class SchedulingService {
  Future<List<TennisMatch>> generateBracket(
    Tournament tournament,
    List<Participant> participants,
  );
}
