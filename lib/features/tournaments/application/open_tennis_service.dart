import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tennis_tournament/features/matches/domain/match.dart';
import 'package:tennis_tournament/features/matches/data/match_repository.dart';
import 'package:tennis_tournament/features/tournaments/domain/group_standing.dart';
import 'package:tennis_tournament/features/tournaments/domain/participant.dart';
import 'package:tennis_tournament/features/tournaments/domain/scheduling_service.dart';
import 'package:tennis_tournament/features/tournaments/domain/tournament.dart';
import 'package:tennis_tournament/features/tournaments/domain/tournament_category.dart';
import 'package:tennis_tournament/features/locations/data/location_repository.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class _MatchSlot {
  final DateTime time;
  final String court;
  _MatchSlot(this.time, this.court);
}

final openTennisServiceProvider = Provider<OpenTennisService>((ref) {
  return OpenTennisService(ref);
});

/// Service for Open Tennis Mode (round-robin groups + playoff bracket)
class OpenTennisService implements SchedulingService {
  final Ref _ref;
  final _uuid = const Uuid();
  final _firestore = FirebaseFirestore.instance;

  OpenTennisService(this._ref);

  @override
  Future<List<TennisMatch>> generateBracket(
    Tournament tournament,
    TournamentCategory category,
    List<Participant> participants, {
    bool shuffle = true,
    List<TennisMatch> additionalOccupiedMatches = const [],
  }) async {
    final matchFormat = tournament.matchRules['matchFormat'] as String? ?? 'roundRobin';
    if (matchFormat == 'crossGroup') {
      return generateCrossGroupMatches(tournament, category, participants, shuffle: shuffle, additionalOccupiedMatches: additionalOccupiedMatches);
    }
    return generateGroupMatches(tournament, category, participants, shuffle: shuffle, additionalOccupiedMatches: additionalOccupiedMatches);
  }

  /// Generate round-robin group stage matches
  Future<List<TennisMatch>> generateGroupMatches(
    Tournament tournament,
    TournamentCategory category,
    List<Participant> participants, {
    bool shuffle = true,
    List<TennisMatch> additionalOccupiedMatches = const [],
  }) async {
    if (participants.length < 2) return [];

    // Get number of courts
    int numberOfCourts = 1;
    if (tournament.locationId != null) {
      try {
        final loc = await _ref.read(locationRepositoryProvider).getLocation(tournament.locationId!);
        if (loc != null) numberOfCourts = loc.numberOfCourts;
      } catch (_) {}
    }

    // Fetch existing matches to avoid conflicts
    List<TennisMatch> existingMatches = [];
    try {
      existingMatches = await _ref.read(matchRepositoryProvider).getMatchesForTournament(tournament.id);
      existingMatches = existingMatches.where((m) => m.categoryId != category.id).toList();
    } catch (_) {}
    existingMatches = [...existingMatches, ...additionalOccupiedMatches];

    // Shuffle if requested
    final players = List<Participant>.from(participants);
    if (shuffle) players.shuffle();

    // tournament.groupCount stores the max players per group.
    // Compute how many groups we need so each has at most maxPerGroup players.
    // Allow one group to have ±1 player so all players fit evenly.
    int maxPerGroup = tournament.groupCount;
    if (maxPerGroup <= 1) maxPerGroup = 4; // default: up to 4 players per group

    int groupCount = (players.length / maxPerGroup).ceil();
    groupCount = groupCount.clamp(1, players.length);

    // Distribute players as evenly as possible.
    // baseSize players per group; the first `extras` groups get one extra player.
    final baseSize = players.length ~/ groupCount;
    final extras = players.length % groupCount;

    final groups = <String, List<Participant>>{};
    int playerIdx = 0;
    for (int g = 0; g < groupCount; g++) {
      final groupId = String.fromCharCode('A'.codeUnitAt(0) + g);
      final size = baseSize + (g < extras ? 1 : 0);
      groups[groupId] = players.sublist(playerIdx, playerIdx + size);
      playerIdx += size;
    }

    // Generate group standings
    await _createGroupStandings(tournament, category, groups);

    // Generate round-robin matches for each group
    final matches = <TennisMatch>[];
    final matchDuration = category.matchDurationMinutes;
    
    DateTime startDate = DateTime.now().add(const Duration(days: 1));
    startDate = DateTime(startDate.year, startDate.month, startDate.day, 9, 0);

    // Generate time slots
    List<_MatchSlot> slots = _generateFallbackSlots(startDate, numberOfCourts, matchDuration, 200, existingMatches);
    int slotIndex = 0;

    for (final entry in groups.entries) {
      final groupId = entry.key;
      final groupPlayers = entry.value;

      // Round-robin: each player plays every other player once
      for (int i = 0; i < groupPlayers.length; i++) {
        for (int j = i + 1; j < groupPlayers.length; j++) {
          final p1 = groupPlayers[i];
          final p2 = groupPlayers[j];

          // Get slot
          DateTime matchTime;
          String courtName;
          if (slotIndex < slots.length) {
            matchTime = slots[slotIndex].time;
            courtName = slots[slotIndex].court;
            slotIndex++;
          } else {
            matchTime = startDate.add(Duration(minutes: matchDuration * slotIndex));
            courtName = 'Court 1';
            slotIndex++;
          }

          final match = TennisMatch(
            id: _uuid.v4(),
            tournamentId: tournament.id,
            categoryId: category.id,
            tournamentName: tournament.name,
            player1Id: p1.id,
            player1Name: p1.name,
            player1UserIds: p1.userIds,
            player1AvatarUrls: p1.avatarUrls,
            player2Id: p2.id,
            player2Name: p2.name,
            player2UserIds: p2.userIds,
            player2AvatarUrls: p2.avatarUrls,
            opponentName: p2.name,
            time: matchTime,
            court: courtName,
            round: 'Group $groupId', // Group stage identifier
            status: 'Preparing',
            matchIndex: matches.length,
            durationMinutes: matchDuration,
            locationId: tournament.locationId,
          );

          matches.add(match);
        }
      }
    }

    return matches;
  }

  /// Generate cross-group matches: round-robin within each group PLUS
  /// extra matches per player against opponents from OTHER groups.
  /// Points from all matches count toward the player's own group standings.
  Future<List<TennisMatch>> generateCrossGroupMatches(
    Tournament tournament,
    TournamentCategory category,
    List<Participant> participants, {
    bool shuffle = true,
    List<TennisMatch> additionalOccupiedMatches = const [],
  }) async {
    if (participants.length < 2) return [];

    int numberOfCourts = 1;
    if (tournament.locationId != null) {
      try {
        final loc = await _ref.read(locationRepositoryProvider).getLocation(tournament.locationId!);
        if (loc != null) numberOfCourts = loc.numberOfCourts;
      } catch (_) {}
    }

    List<TennisMatch> existingMatches = [];
    try {
      existingMatches = await _ref.read(matchRepositoryProvider).getMatchesForTournament(tournament.id);
      existingMatches = existingMatches.where((m) => m.categoryId != category.id).toList();
    } catch (_) {}
    existingMatches = [...existingMatches, ...additionalOccupiedMatches];

    final players = List<Participant>.from(participants);
    if (shuffle) players.shuffle();

    // Build groups (reuse same distribution logic)
    int maxPerGroup = tournament.groupCount;
    if (maxPerGroup <= 1) maxPerGroup = 4;
    int groupCount = (players.length / maxPerGroup).ceil();
    groupCount = groupCount.clamp(1, players.length);
    final baseSize = players.length ~/ groupCount;
    final extras = players.length % groupCount;

    final groups = <String, List<Participant>>{};
    int playerIdx = 0;
    for (int g = 0; g < groupCount; g++) {
      final groupId = String.fromCharCode('A'.codeUnitAt(0) + g);
      final size = baseSize + (g < extras ? 1 : 0);
      groups[groupId] = players.sublist(playerIdx, playerIdx + size);
      playerIdx += size;
    }

    // Create standings
    await _createGroupStandings(tournament, category, groups);

    // Build player-to-group map
    final playerGroup = <String, String>{};
    for (final entry in groups.entries) {
      for (final p in entry.value) {
        playerGroup[p.id] = entry.key;
      }
    }

    final matchDuration = category.matchDurationMinutes;
    DateTime startDate = DateTime.now().add(const Duration(days: 1));
    startDate = DateTime(startDate.year, startDate.month, startDate.day, 9, 0);

    final allMatchPairs = <(Participant, Participant, String)>[];

    // ── Step 1: Round-robin within each group ──
    for (final entry in groups.entries) {
      final groupId = entry.key;
      final groupPlayers = entry.value;
      for (int i = 0; i < groupPlayers.length; i++) {
        for (int j = i + 1; j < groupPlayers.length; j++) {
          allMatchPairs.add((groupPlayers[i], groupPlayers[j], 'Group $groupId'));
        }
      }
    }

    // ── Step 2: Extra cross-group matches ──
    final extraMatchesPerPlayer = tournament.matchRules['matchesPerPlayer'] as int? ?? 1;
    final crossMatchCount = <String, int>{};
    for (final p in players) {
      crossMatchCount[p.id] = 0;
    }

    final scheduledPairs = <String>{};
    // Mark intra-group pairs as already scheduled
    for (final (p1, p2, _) in allMatchPairs) {
      scheduledPairs.add('${p1.id}_${p2.id}');
    }

    final shuffledPlayers = List<Participant>.from(players)..shuffle();
    for (final p1 in shuffledPlayers) {
      if (crossMatchCount[p1.id]! >= extraMatchesPerPlayer) continue;
      final p1Group = playerGroup[p1.id]!;

      final candidates = players
          .where((p2) =>
              playerGroup[p2.id] != p1Group &&
              crossMatchCount[p2.id]! < extraMatchesPerPlayer &&
              !scheduledPairs.contains('${p1.id}_${p2.id}') &&
              !scheduledPairs.contains('${p2.id}_${p1.id}'))
          .toList()
        ..shuffle();

      for (final p2 in candidates) {
        if (crossMatchCount[p1.id]! >= extraMatchesPerPlayer) break;

        scheduledPairs.add('${p1.id}_${p2.id}');
        crossMatchCount[p1.id] = crossMatchCount[p1.id]! + 1;
        crossMatchCount[p2.id] = crossMatchCount[p2.id]! + 1;
        final p2Group = playerGroup[p2.id]!;
        allMatchPairs.add((p1, p2, 'Cross $p1Group-$p2Group'));
      }
    }

    // ── Step 3: Generate time slots and create match objects ──
    List<_MatchSlot> slots = _generateFallbackSlots(startDate, numberOfCourts, matchDuration, allMatchPairs.length + 50, existingMatches);
    int slotIndex = 0;

    final matches = <TennisMatch>[];
    for (final (p1, p2, p1Group) in allMatchPairs) {
      DateTime matchTime;
      String courtName;
      if (slotIndex < slots.length) {
        matchTime = slots[slotIndex].time;
        courtName = slots[slotIndex].court;
        slotIndex++;
      } else {
        matchTime = startDate.add(Duration(minutes: matchDuration * slotIndex));
        courtName = 'Court 1';
        slotIndex++;
      }

      matches.add(TennisMatch(
        id: _uuid.v4(),
        tournamentId: tournament.id,
        categoryId: category.id,
        tournamentName: tournament.name,
        player1Id: p1.id,
        player1Name: p1.name,
        player1UserIds: p1.userIds,
        player1AvatarUrls: p1.avatarUrls,
        player2Id: p2.id,
        player2Name: p2.name,
        player2UserIds: p2.userIds,
        player2AvatarUrls: p2.avatarUrls,
        opponentName: p2.name,
        time: matchTime,
        court: courtName,
        round: p1Group,
        status: 'Preparing',
        matchIndex: matches.length,
        durationMinutes: matchDuration,
        locationId: tournament.locationId,
      ));
    }

    return matches;
  }

  /// Create group standings in Firestore
  Future<void> _createGroupStandings(
    Tournament tournament,
    TournamentCategory category,
    Map<String, List<Participant>> groups,
  ) async {
    final batch = _firestore.batch();

    for (final entry in groups.entries) {
      final groupId = entry.key;
      final players = entry.value;

      for (final player in players) {
        final standing = GroupStanding(
          id: _uuid.v4(),
          tournamentId: tournament.id,
          categoryId: category.id,
          groupId: groupId,
          participantId: player.id,
          participantName: player.name,
          participantUserIds: player.userIds,
          participantAvatarUrls: player.avatarUrls,
        );

        final docRef = _firestore
            .collection('tournaments')
            .doc(tournament.id)
            .collection('standings')
            .doc(standing.id);

        batch.set(docRef, standing.toJson());
      }
    }

    await batch.commit();
  }

  /// Update standings after a match is completed
  Future<void> updateStandingsAfterMatch(
    String tournamentId,
    String categoryId,
    String winnerId,
    String loserId,
    int pointsPerWin,
  ) async {
    // Get winner standing
    final winnerQuery = await _firestore
        .collection('tournaments')
        .doc(tournamentId)
        .collection('standings')
        .where('categoryId', isEqualTo: categoryId)
        .where('participantId', isEqualTo: winnerId)
        .limit(1)
        .get();

    if (winnerQuery.docs.isNotEmpty) {
      await winnerQuery.docs.first.reference.update({
        'matchesPlayed': FieldValue.increment(1),
        'wins': FieldValue.increment(1),
        'points': FieldValue.increment(pointsPerWin),
      });
    }

    // Get loser standing
    final loserQuery = await _firestore
        .collection('tournaments')
        .doc(tournamentId)
        .collection('standings')
        .where('categoryId', isEqualTo: categoryId)
        .where('participantId', isEqualTo: loserId)
        .limit(1)
        .get();

    if (loserQuery.docs.isNotEmpty) {
      await loserQuery.docs.first.reference.update({
        'matchesPlayed': FieldValue.increment(1),
        'losses': FieldValue.increment(1),
      });
    }
  }

  /// Get group standings for a tournament category
  Future<Map<String, List<GroupStanding>>> getGroupStandings(
    String tournamentId,
    String categoryId,
  ) async {
    final snapshot = await _firestore
        .collection('tournaments')
        .doc(tournamentId)
        .collection('standings')
        .where('categoryId', isEqualTo: categoryId)
        .get();

    final standings = snapshot.docs
        .map((doc) => GroupStanding.fromJson(doc.data()))
        .toList();

    // Group by groupId
    final grouped = <String, List<GroupStanding>>{};
    for (final s in standings) {
      grouped.putIfAbsent(s.groupId, () => []);
      grouped[s.groupId]!.add(s);
    }

    // Sort each group by points (descending)
    for (final group in grouped.values) {
      group.sort((a, b) => b.points.compareTo(a.points));
    }

    return grouped;
  }

  /// Check if group stage is complete
  Future<bool> isGroupStageComplete(
    String tournamentId,
    String categoryId,
  ) async {
    final matches = await _ref.read(matchRepositoryProvider).getMatchesForTournament(tournamentId);
    final groupMatches = matches.where((m) =>
        m.categoryId == categoryId && (m.round.startsWith('Group') || m.round.startsWith('Cross')));

    return groupMatches.isNotEmpty &&
        groupMatches.every((m) => m.status == 'Completed' || m.status == 'Finished');
  }

  /// Generate playoff bracket from group winners
  Future<List<TennisMatch>> generatePlayoffBracket(
    Tournament tournament,
    TournamentCategory category,
  ) async {
    // Get group standings
    final standings = await getGroupStandings(tournament.id, category.id);
    
    // Get top players from each group based on advanceCount
    final advanceCount = tournament.advanceCount.clamp(1, 99);
    final scoringMode = tournament.matchRules['scoringMode'] as String? ?? 'flat';
    final sameGroupPlayoff = scoringMode == 'variable' && advanceCount == 2;

    final qualifiedPlayers = <Participant>[];
    // For same-group playoff, collect pairs per group: [1stA, 2ndA, 1stB, 2ndB, ...]
    for (final group in standings.entries) {
      final topN = group.value.take(advanceCount);
      for (final player in topN) {
        qualifiedPlayers.add(Participant(
          id: player.participantId,
          name: player.participantName,
          categoryId: category.id,
          userIds: player.participantUserIds,
          avatarUrls: player.participantAvatarUrls,
          status: 'approved',
          joinedAt: DateTime.now(),
        ));
      }
    }

    if (qualifiedPlayers.length < 2) return [];

    // For same-group playoff: players are already ordered [1stA, 2ndA, 1stB, 2ndB, ...]
    // so the default i/i+1 pairing naturally pairs within the same group.
    // For cross-group (flat scoring), reorder so 1st seeds face 2nd seeds from other groups.
    if (!sameGroupPlayoff && advanceCount == 2 && qualifiedPlayers.length >= 4) {
      // Reorder: [1stA, 2ndB, 1stB, 2ndA, ...] for cross-group seeding
      final reordered = <Participant>[];
      final firsts = <Participant>[];
      final seconds = <Participant>[];
      for (int i = 0; i < qualifiedPlayers.length; i++) {
        if (i % 2 == 0) {
          firsts.add(qualifiedPlayers[i]);
        } else {
          seconds.add(qualifiedPlayers[i]);
        }
      }
      for (int i = 0; i < firsts.length; i++) {
        reordered.add(firsts[i]);
        // Pair with 2nd from the opposite end
        final j = (seconds.length - 1) - i;
        if (j >= 0 && j < seconds.length) {
          reordered.add(seconds[j]);
        }
      }
      qualifiedPlayers
        ..clear()
        ..addAll(reordered);
    }

    // Use SingleEliminationService for playoff
    // Import and delegate to SingleEliminationService
    // For simplicity, generate inline here

    // Get number of courts
    int numberOfCourts = 1;
    if (tournament.locationId != null) {
      try {
        final loc = await _ref.read(locationRepositoryProvider).getLocation(tournament.locationId!);
        if (loc != null) numberOfCourts = loc.numberOfCourts;
      } catch (_) {}
    }

    final existingMatches = await _ref.read(matchRepositoryProvider).getMatchesForTournament(tournament.id);
    final matchDuration = category.matchDurationMinutes;
    
    DateTime startDate = DateTime.now().add(const Duration(days: 1));
    startDate = DateTime(startDate.year, startDate.month, startDate.day, 9, 0);

    List<_MatchSlot> slots = _generateFallbackSlots(startDate, numberOfCourts, matchDuration, 100, existingMatches);
    int slotIndex = 0;

    // Simple bracket generation for qualified players
    final matches = <TennisMatch>[];
    final n = qualifiedPlayers.length;
    int round = 1;
    var currentPlayers = qualifiedPlayers;

    while (currentPlayers.length >= 2) {
      final roundMatches = <TennisMatch>[];
      
      for (int i = 0; i < currentPlayers.length; i += 2) {
        if (i + 1 >= currentPlayers.length) break; // Odd player gets bye

        final p1 = currentPlayers[i];
        final p2 = currentPlayers[i + 1];

        DateTime matchTime;
        String courtName;
        if (slotIndex < slots.length) {
          matchTime = slots[slotIndex].time;
          courtName = slots[slotIndex].court;
          slotIndex++;
        } else {
          matchTime = startDate.add(Duration(minutes: matchDuration * slotIndex));
          courtName = 'Court 1';
          slotIndex++;
        }

        final match = TennisMatch(
          id: _uuid.v4(),
          tournamentId: tournament.id,
          categoryId: category.id,
          tournamentName: tournament.name,
          player1Id: p1.id,
          player1Name: p1.name,
          player1UserIds: p1.userIds,
          player1AvatarUrls: p1.avatarUrls,
          player2Id: p2.id,
          player2Name: p2.name,
          player2UserIds: p2.userIds,
          player2AvatarUrls: p2.avatarUrls,
          opponentName: p2.name,
          time: matchTime,
          court: courtName,
          round: 'Playoff R$round',
          status: 'Preparing',
          matchIndex: roundMatches.length,
          durationMinutes: matchDuration,
          locationId: tournament.locationId,
        );

        roundMatches.add(match);
      }

      matches.addAll(roundMatches);
      round++;
      
      // Next round players will be winners (TBD for now)
      // For initial generation, just break after first round
      // Winners get populated as matches complete
      break;
    }

    return matches;
  }

  List<_MatchSlot> _generateFallbackSlots(
    DateTime startDate,
    int numberOfCourts,
    int durationMinutes,
    int countNeeded,
    List<TennisMatch> existingMatches,
  ) {
    List<_MatchSlot> slots = [];
    DateTime current = startDate;
    int added = 0;
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

      if (current.hour >= 20) {
        current = DateTime(current.year, current.month, current.day + 1, 9, 0);
      }
    }
    return slots;
  }

  bool _isSlotOccupied(
    _MatchSlot slot,
    List<TennisMatch> existingMatches,
    int durationMinutes, {
    int totalCourts = 1,
  }) {
    final slotStart = slot.time;
    final slotEnd = slotStart.add(Duration(minutes: durationMinutes));
    int overlappingCount = 0;
    for (var match in existingMatches) {
      final matchStart = match.time;
      final matchEnd = matchStart.add(Duration(minutes: match.durationMinutes));
      if (slotStart.isBefore(matchEnd) && slotEnd.isAfter(matchStart)) {
        if (match.court == slot.court) return true;
        overlappingCount++;
      }
    }
    return overlappingCount >= totalCourts;
  }
}
