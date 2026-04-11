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
    List<TennisMatch> additionalOccupiedMatches = const [],
    bool scheduleDatesAndTimes = false,
  });

  /// Auto-schedules dates and times for a list of matches that don't have them yet.
  Future<List<TennisMatch>> assignSlotsToMatches(
    Tournament tournament,
    List<TennisMatch> matchesToSchedule,
    DateTime startDate, {
    List<TennisMatch> additionalOccupiedMatches = const [],
  });
}
