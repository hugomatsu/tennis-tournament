import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tennis_tournament/features/matches/domain/match.dart';
import 'package:tennis_tournament/features/matches/data/match_repository.dart';
import 'package:tennis_tournament/features/tournaments/domain/participant.dart';
import 'package:tennis_tournament/features/tournaments/domain/scheduling_service.dart';
import 'package:tennis_tournament/features/tournaments/domain/tournament.dart';
import 'package:tennis_tournament/features/tournaments/domain/tournament_category.dart';
import 'package:tennis_tournament/features/locations/data/location_repository.dart';
import 'package:tennis_tournament/features/locations/domain/location.dart';
import 'package:tennis_tournament/features/tournaments/application/americano_service.dart';
import 'package:tennis_tournament/features/tournaments/application/open_tennis_service.dart';
import 'package:uuid/uuid.dart';

class _MatchSlot {
  final DateTime time;
  final String court;
  
  _MatchSlot(this.time, this.court);
}

/// Default provider - returns SingleElimination (mata-mata) service
final schedulingServiceProvider = Provider<SchedulingService>((ref) {
  return SingleEliminationService(ref);
});

/// Provider that selects service based on tournament type
final schedulingServiceForTournamentProvider = Provider.family<SchedulingService, String>((ref, tournamentType) {
  if (tournamentType == 'openTennis') {
    return OpenTennisService(ref);
  }
  if (tournamentType == 'americano') {
    return AmericanoService(ref);
  }
  return SingleEliminationService(ref);
});

class SingleEliminationService implements SchedulingService {
  final Ref _ref;
  final _uuid = const Uuid();

  SingleEliminationService(this._ref);

  @override
  Future<List<TennisMatch>> assignSlotsToMatches(
    Tournament tournament,
    List<TennisMatch> matchesToSchedule,
    DateTime startDate, {
    List<TennisMatch> additionalOccupiedMatches = const [],
  }) async {
    final rules = tournament.scheduleRules;
    final matchRules = tournament.matchRules;
    final duration = matchRules['matchDurationMinutes'] as int? ?? 90;

    // SingleElimination uses a different _generateSlots signature:
    // List<_MatchSlot> _generateSlots(List<DailySchedule> rules, int matchDurationMinutes)
    
    final slots = _generateSlots(
      rules,
      duration,
    );
    
    // We also need to filter out slots that are occupied
    // But since this is a basic override, let's just use what slots we have.
    // We can do a rudimentary sweep for occupied.
    final availableSlots = slots.where((slot) => !_isSlotOccupied(slot, additionalOccupiedMatches, duration)).toList();

    for (int i = 0; i < matchesToSchedule.length; i++) {
        matchesToSchedule[i] = matchesToSchedule[i].copyWith(
          time: i < availableSlots.length ? availableSlots[i].time : null,
          court: i < availableSlots.length ? availableSlots[i].court : '',
        );
    }
    return matchesToSchedule;
  }

  @override
  Future<List<TennisMatch>> generateBracket(
    Tournament tournament,
    TournamentCategory category,
    List<Participant> participants, {
    List<TennisMatch> additionalOccupiedMatches = const [],
    bool scheduleDatesAndTimes = true,
    bool shuffle = false,
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
    
    // Fetch all existing matches for this tournament to check for overlaps
    List<TennisMatch> existingMatches = [];
    try {
      existingMatches = await _ref.read(matchRepositoryProvider).getMatchesForTournament(tournament.id);
      // Exclude matches from the CURRENT category (we are regenerating it, so we ignore its old matches if any)
      // Actually, if we are regenerating, the repository might still have the old ones unless we deleted them first.
      // Usually, the UI might delete before calling generate, or generate returns NEW matches and we save them.
      // We should assume we ignore matches of this categoryId to be safe/flexible.
      existingMatches = existingMatches.where((m) => m.categoryId != category.id).toList();
    } catch (_) {
      // If fails, process without conflict checks (fallback)
    }
    // Merge in-memory matches from previously generated categories (sequential scheduling)
    existingMatches = [...existingMatches, ...additionalOccupiedMatches];

    // Parse start date
    DateTime startDate = DateTime.now().add(const Duration(days: 1));
    startDate = DateTime(startDate.year, startDate.month, startDate.day, 9, 0);

    final matchDuration = category.matchDurationMinutes;

    // 1. Shuffle players if requested
    final shuffledPlayers = List<Participant>.from(participants);
    if (shuffle) {
      shuffledPlayers.shuffle();
    }

    // 2. Calculate bracket size
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
    
    // Filter out rules-based slots that are already occupied
    slots = slots.where((slot) => !_isSlotOccupied(slot, existingMatches, matchDuration, totalCourts: numberOfCourts)).toList();
    
    // If no slots generated (or no rules), or we ran out due to conflicts, fallback
    if (slots.isEmpty || slots.length < bracketSize) { // basic check, we might need more
       // Append fallback slots, checking for conflicts
       // Use a start date at least as late as the last rule slot if exists, or global start date
       DateTime fallbackStart = startDate;
       if (slots.isNotEmpty) {
         // Start checking from the time of the last valid slot? 
         // Or just keep using startDate logic but _generateValidFallbackSlots will handle skipping.
         // Let's rely on _generateValidFallbackSlots starting from startDate but skipping occupied.
       }
       
       // Calculate how many more we need approximately. 
       // We'll just generate a large batch (200) of VALID slots to be safe.
       final moreSlots = _generateValidFallbackSlots(fallbackStart, numberOfCourts, matchDuration, 200, existingMatches);
       slots.addAll(moreSlots);
    }

    int slotIndex = 0;

    for (int r = 1; r <= totalRounds; r++) {
      
      for (int i = 0; i < matchesInRound; i++) {
        final matchId = _uuid.v4();
        
        // Calculate Time and Court
        DateTime matchTime;
        String courtName;

        // Use valid pre-calculated slots
        if (slotIndex < slots.length) {
            matchTime = slots[slotIndex].time;
            courtName = slots[slotIndex].court;
            slotIndex++;
        } else {
             // Emergency Fallback if we somehow ran out of valid slots (unlikely with 200 buffer)
             // Find next available time blindly (simple projection)
             // We'll just use a far future or append to last known time without checking (risky but rare)
             matchTime = startDate.add(Duration(minutes: matchDuration * slotIndex)); 
             courtName = 'Court 1'; 
             slotIndex++;
        }
        
        // ... (rest of loop matches original)
        // [TRUNCATED for brevity, we only needed to change slot generation logic]
        // But since replace_tool requires context, I'll return the loop logic or careful splice.
        // Actually I need to be careful not to delete the loop body.
        
        // Let's refactor the replacement to target up to the loop start.
        // I will finish the logic here and assume the tool call uses a narrower range or I include the loop start.
        
        // Wait, replace_file_content replaces a block. I must provide the block to replace.
        // The instruction is to modify lines 38-112 (approx).
        
        // ...
      

        



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
          categoryName: category.name,
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
          time: scheduleDatesAndTimes ? matchTime : null,
          court: scheduleDatesAndTimes ? courtName : null,
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


  
  DateTime? _parseTime(String dateStr, String timeStr) {
    try {
      // dateStr: yyyy-MM-dd
      // timeStr: HH:mm
      return DateFormat('yyyy-MM-dd HH:mm').parse('$dateStr $timeStr');
    } catch (e) {
      return null;
    }
  }

  // Helper to check overlap.
  // A slot is occupied if:
  //   (a) the specific court has a match overlapping this time window, OR
  //   (b) ALL courts are already used at this time window (capacity full across categories)
  bool _isSlotOccupied(
    _MatchSlot slot,
    List<TennisMatch> existingMatches,
    int durationMinutes, {
    int totalCourts = 1,
  }) {
    final slotStart = slot.time;
    final slotEnd = slotStart.add(Duration(minutes: durationMinutes));

    int overlappingCount = 0;
    for (final match in existingMatches) {
      if (match.time == null) continue;
      final matchStart = match.time!;
      final matchEnd = matchStart.add(Duration(minutes: match.durationMinutes));
      if (slotStart.isBefore(matchEnd) && slotEnd.isAfter(matchStart)) {
        // Same court — direct conflict
        if (match.court == slot.court) return true;
        overlappingCount++;
      }
    }
    // All courts are full at this time window
    return overlappingCount >= totalCourts;
  }

  List<_MatchSlot> _generateValidFallbackSlots(
    DateTime startDate, 
    int numberOfCourts, 
    int durationMinutes, 
    int countNeeded,
    List<TennisMatch> existingMatches
  ) {
    List<_MatchSlot> slots = [];
    DateTime current = startDate;
    int added = 0;
    
    // Safety break to prevent infinite loops if calendar is full
    int attempts = 0;
    const maxAttempts = 5000; 

    while (added < countNeeded && attempts < maxAttempts) {
       for (int c = 1; c <= numberOfCourts; c++) {
          final candidate = _MatchSlot(current, 'Court $c');
          if (!_isSlotOccupied(candidate, existingMatches, durationMinutes, totalCourts: numberOfCourts)) {
            slots.add(candidate);
            added++;
          }
       }
       
       current = current.add(Duration(minutes: durationMinutes));
       attempts++;

       // If too late (e.g. 8pm), move to next day 9am 
       if (current.hour >= 20) {
         current = DateTime(current.year, current.month, current.day + 1, 9, 0);
       }
    }
    return slots;
  }
}
