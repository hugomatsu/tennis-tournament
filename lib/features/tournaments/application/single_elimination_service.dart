import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tennis_tournament/features/matches/domain/match.dart';
import 'package:tennis_tournament/features/tournaments/domain/participant.dart';
import 'package:tennis_tournament/features/tournaments/domain/scheduling_service.dart';
import 'package:tennis_tournament/features/tournaments/domain/tournament.dart';
import 'package:tennis_tournament/features/tournaments/domain/tournament_category.dart';
import 'package:tennis_tournament/features/locations/data/location_repository.dart';
import 'package:tennis_tournament/features/locations/domain/location.dart';
import 'package:uuid/uuid.dart';

final schedulingServiceProvider = Provider<SchedulingService>((ref) {
  return SingleEliminationService(ref);
});

class SingleEliminationService implements SchedulingService {
  final Ref _ref;
  final _uuid = const Uuid();

  SingleEliminationService(this._ref);

  @override
  Future<List<TennisMatch>> generateBracket(
    Tournament tournament,
    TournamentCategory category,
    List<Participant> participants, {
    bool shuffle = true,
  }) async {
    if (participants.length < 2) return [];

    // 0. Fetch Location info for Courts
    int numberOfCourts = 1;
    if (tournament.locationId != null) {
      try {
        final loc = await _ref.read(locationRepositoryProvider).getLocation(tournament.locationId!);
        if (loc != null) {
          numberOfCourts = loc.numberOfCourts;
        }
      } catch (_) {}
    }

    // Parse start date
    DateTime startDate = DateTime.now().add(const Duration(days: 1));
    startDate = DateTime(startDate.year, startDate.month, startDate.day, 9, 0);

    final matchDuration = category.matchDurationMinutes;

    // 1. Shuffle players if requested, otherwise use provided order
    final shuffledPlayers = List<Participant>.from(participants);
    if (shuffle) {
      shuffledPlayers.shuffle();
    }

    // 2. Calculate bracket size and byes
    final n = shuffledPlayers.length;
    final bracketSize = _nextPowerOfTwo(n);
    final byesCount = bracketSize - n;

    final matches = <TennisMatch>[];
    final matchMap = <String, TennisMatch>{};
    
    int totalRounds = 0;
    int temp = bracketSize;
    while (temp > 1) {
      temp >>= 1;
      totalRounds++;
    }

    int matchesInRound = bracketSize ~/ 2;
    int playerIndex = 0;

    for (int r = 1; r <= totalRounds; r++) {
      final roundDate = startDate.add(Duration(days: r - 1));

      for (int i = 0; i < matchesInRound; i++) {
        final matchId = _uuid.v4();
        
        // Calculate Time and Court
        final matchTime = roundDate.add(Duration(minutes: (i * matchDuration)));
        final courtName = 'Court ${(i % numberOfCourts) + 1}';

        // Determine players for Round 1
        String player1Id = '';
        String player1Name = 'TBD';
        List<String> p1UserIds = [];
        List<String?> p1Avatars = [];
        
        String? player2Id;
        String? player2Name;
        List<String> p2UserIds = [];
        List<String?> p2Avatars = [];
        
        String status = 'Preparing';
        String? winner;
        String? score;
        String opponentName = 'TBD';

        if (r == 1) {
          final isByeMatch = i < byesCount;
          
          final p1 = shuffledPlayers[playerIndex++];
          player1Id = p1.id;
          player1Name = p1.name;
          p1UserIds = p1.userIds;
          p1Avatars = p1.avatarUrls;

          if (isByeMatch) {
            status = 'Completed';
            winner = p1.name;
            score = 'Bye';
            opponentName = 'BYE';
            // Player 2 stays empty/null
          } else {
            final p2 = shuffledPlayers[playerIndex++];
            player2Id = p2.id;
            player2Name = p2.name;
            p2UserIds = p2.userIds;
            p2Avatars = p2.avatarUrls;
            opponentName = p2.name;
            status = 'Preparing';
          }
        } else {
           // Future rounds TBD
        }

        final match = TennisMatch(
          id: matchId,
          tournamentId: tournament.id,
          categoryId: category.id,
          tournamentName: tournament.name,
          player1Id: player1Id,
          player1Name: player1Name,
          player1UserIds: p1UserIds,
          player1AvatarUrls: p1Avatars,
          player2Id: player2Id,
          player2Name: player2Name,
          player2UserIds: p2UserIds,
          player2AvatarUrls: p2Avatars,
          opponentName: opponentName,
          time: matchTime,
          court: courtName,
          round: r.toString(),
          status: status,
          score: score,
          winner: winner,
          matchIndex: i,
          durationMinutes: matchDuration,
          locationId: tournament.locationId,
        );
        
        matchMap['${r}_$i'] = match;
        matches.add(match);
      }
      matchesInRound ~/= 2;
    }

    // Link matches (Next Match ID) and propagate Byes
    matches.sort((a, b) {
      final rA = int.parse(a.round);
      final rB = int.parse(b.round);
      return rA.compareTo(rB);
    });

    final mutableMatchMap = {for (var m in matches) m.id: m};
    final positionMap = <String, String>{}; 
    for (var m in matches) {
      positionMap['${m.round}_${m.matchIndex}'] = m.id;
    }

    for (var match in matches) {
      final r = int.parse(match.round);
      final idx = match.matchIndex;
      
      // Find next match
      if (r < totalRounds) {
        final nextRound = r + 1;
        final nextIndex = idx ~/ 2;
        final nextMatchId = positionMap['${nextRound}_$nextIndex'];
        
        if (nextMatchId != null) {
           // Update current match with nextMatchId
           var updatedMatch = mutableMatchMap[match.id]!.copyWith(nextMatchId: nextMatchId);
           mutableMatchMap[match.id] = updatedMatch;
           
           // Propagate winner if this match is already completed (Bye)
           if (updatedMatch.status == 'Completed' && updatedMatch.winner != null) {
             final nextMatch = mutableMatchMap[nextMatchId]!;
             final isPlayer1Slot = (idx % 2) == 0;
             
             // Define winner info
             String? winnerId;
             String? winnerName;
             List<String> winnerUserIds = [];
             List<String?> winnerAvatars = [];
             
             if (updatedMatch.winner == updatedMatch.player1Name) {
               winnerId = updatedMatch.player1Id;
               winnerName = updatedMatch.player1Name;
               winnerUserIds = updatedMatch.player1UserIds;
               winnerAvatars = updatedMatch.player1AvatarUrls;
             } else {
               winnerId = updatedMatch.player2Id;
               winnerName = updatedMatch.player2Name;
               winnerUserIds = updatedMatch.player2UserIds;
               winnerAvatars = updatedMatch.player2AvatarUrls;
             }

             if (winnerId != null && winnerName != null) {
                // Update next match
                TennisMatch newNextMatch;
                if (isPlayer1Slot) {
                  newNextMatch = nextMatch.copyWith(
                    player1Id: winnerId,
                    player1Name: winnerName,
                    player1UserIds: winnerUserIds,
                    player1AvatarUrls: winnerAvatars,
                  );
                } else {
                  newNextMatch = nextMatch.copyWith(
                    player2Id: winnerId,
                    player2Name: winnerName,
                    player2UserIds: winnerUserIds,
                    player2AvatarUrls: winnerAvatars,
                    opponentName: winnerName, // Legacy
                  );
                }
                mutableMatchMap[nextMatchId] = newNextMatch;
             }
           }
        }
      }
    }

    return mutableMatchMap.values.toList();
  }

  int _nextPowerOfTwo(int n) {
    int count = 0;
    if (n > 0 && (n & (n - 1)) == 0) return n;
    while (n != 0) {
      n >>= 1;
      count += 1;
    }
    return 1 << count;
  }
}
