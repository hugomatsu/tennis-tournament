import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tennis_tournament/features/matches/domain/match.dart';
import 'package:tennis_tournament/features/tournaments/domain/participant.dart';
import 'package:tennis_tournament/features/tournaments/domain/scheduling_service.dart';
import 'package:tennis_tournament/features/tournaments/domain/tournament.dart';
import 'package:tennis_tournament/features/tournaments/domain/tournament_category.dart';
import 'package:tennis_tournament/features/locations/data/location_repository.dart';
import 'package:tennis_tournament/features/locations/domain/location.dart';
import 'package:uuid/uuid.dart';

class _MatchSlot {
  final DateTime time;
  final String court;
  
  _MatchSlot(this.time, this.court);
}

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

    // 3. Generate Slots from Rules (or fallback)
    List<_MatchSlot> slots = [];
    if (tournament.scheduleRules.isNotEmpty) {
      slots = _generateSlots(tournament.scheduleRules, matchDuration);
    } 
    
    // If no slots generated (or no rules), fallback to default: tomorrow 9am, 1 court (or tournament location courts)
    if (slots.isEmpty) {
       // Fallback logic matches original behavior but slotified
       slots = _generateFallbackSlots(startDate, numberOfCourts, matchDuration, bracketSize); // Generate enough for max likely matches
    }

    int slotIndex = 0;

    for (int r = 1; r <= totalRounds; r++) {
      
      for (int i = 0; i < matchesInRound; i++) {
        final matchId = _uuid.v4();
        
        // Calculate Time and Court
        // Default to TBD if run out of slots
        DateTime matchTime = startDate.add(Duration(days: 365)); // Far future fallback
        String courtName = 'Stack Overflow Court';

        if (slotIndex < slots.length) {
            matchTime = slots[slotIndex].time;
            courtName = slots[slotIndex].court;
            slotIndex++;
        } else {
             // Dynamic expansion fallback if we ran out of pre-calculated slots
             // Just add on to the last slot's time + duration
             // This is a safety valve
             matchTime = matchTime.add(Duration(minutes: matchDuration * (slotIndex - slots.length)));
        }

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
            
            // Note: Byes effectively consume a slot technically in this loop structure, 
            // but usually Byes don't have a time. 
            // However for simplicity we let them take a slot or we could skip incrementing slotIndex for Byes.
            // Let's SKIP slot index for Byes so they don't consume real court time.
            if (slotIndex > 0) slotIndex--; 
            
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

  List<_MatchSlot> _generateSlots(List<DailySchedule> rules, int matchDurationMinutes) {
    List<_MatchSlot> slots = [];
    
    // Sort rules by date just in case
    // We assume rules are valid and no overlap for now
    
    for (var rule in rules) {
      DateTime? start = _parseTime(rule.date, rule.startTime);
      DateTime? end = _parseTime(rule.date, rule.endTime);
      
      if (start == null || end == null) continue;
      
      // Calculate how many matches fit per court
      // We iterate by time steps
      DateTime current = start;
      while (current.add(Duration(minutes: matchDurationMinutes)).isBefore(end) || 
             current.add(Duration(minutes: matchDurationMinutes)).isAtSameMomentAs(end)) {
        
        for (int c = 1; c <= rule.courtCount; c++) {
          slots.add(_MatchSlot(current, 'Court $c'));
        }
        current = current.add(Duration(minutes: matchDurationMinutes));
      }
    }
    
    return slots;
  }

  List<_MatchSlot> _generateFallbackSlots(DateTime startDate, int numberOfCourts, int durationMinutes, int totalMatchesEstimate) {
    List<_MatchSlot> slots = [];
    DateTime current = startDate;
    int matchesGenerated = 0;
    
    // Generate enough slots for a reasonable number of matches (e.g. 100 or totalMatches)
    // We'll generate 200 to be safe
    while (matchesGenerated < 200) {
       for (int c = 1; c <= numberOfCourts; c++) {
          slots.add(_MatchSlot(current, 'Court $c'));
          matchesGenerated++;
       }
       current = current.add(Duration(minutes: durationMinutes));
       
       // If too late (e.g. 8pm), move to next day 9am 
       if (current.hour >= 20) {
         current = DateTime(current.year, current.month, current.day + 1, 9, 0);
       }
    }
    return slots;
  }
  
  DateTime? _parseTime(String dateStr, String timeStr) {
    try {
      // dateStr: yyyy-MM-dd
      // timeStr: HH:mm
      return DateFormat('yyyy-MM-dd HH:mm').parse('$dateStr $timeStr');
    } catch (e) {
      return null;
    }
  }

}
