import 'package:flutter_riverpod/flutter_riverpod.dart';
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

final americanoServiceProvider = Provider<AmericanoService>((ref) {
  return AmericanoService(ref);
});

/// Service for Americano Mode:
/// Phase 1 — Cross-group rounds (guaranteed N matches each, no intra-group)
/// Phase 2 — Group deciders (top 2 per group play each other)
/// Phase 3 — Single-elimination playoff (decider winners)
class AmericanoService implements SchedulingService {
  final Ref _ref;
  final _uuid = const Uuid();
  final _firestore = FirebaseFirestore.instance;

  AmericanoService(this._ref);

  @override
  Future<List<TennisMatch>> generateBracket(
    Tournament tournament,
    TournamentCategory category,
    List<Participant> participants, {
    bool shuffle = true,
  }) async {
    return generateCrossGroupRounds(tournament, category, participants, shuffle: shuffle);
  }

  /// Phase 1: Generate guaranteed cross-group matches for all players.
  /// Each player plays [guaranteedMatches] matches against players from other groups.
  Future<List<TennisMatch>> generateCrossGroupRounds(
    Tournament tournament,
    TournamentCategory category,
    List<Participant> participants, {
    bool shuffle = true,
  }) async {
    if (participants.length < 2) return [];

    final guaranteedMatches = tournament.matchRules['guaranteedMatches'] as int? ?? 5;
    final playersPerGroup = tournament.groupCount > 1 ? tournament.groupCount : 4;

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

    final players = List<Participant>.from(participants);
    if (shuffle) players.shuffle();

    // Build groups
    final groupCount = (players.length / playersPerGroup).ceil().clamp(1, players.length);
    final baseSize = players.length ~/ groupCount;
    final extras = players.length % groupCount;

    final groups = <String, List<Participant>>{};
    final playerGroup = <String, String>{};
    int playerIdx = 0;
    for (int g = 0; g < groupCount; g++) {
      final groupId = String.fromCharCode('A'.codeUnitAt(0) + g);
      final size = baseSize + (g < extras ? 1 : 0);
      groups[groupId] = players.sublist(playerIdx, playerIdx + size);
      for (final p in groups[groupId]!) {
        playerGroup[p.id] = groupId;
      }
      playerIdx += size;
    }

    await _createGroupStandings(tournament, category, groups);

    // Greedy cross-group pairing — guarantee N matches per player, no rematches, no intra-group
    final matchesRemaining = {for (final p in players) p.id: guaranteedMatches};
    final scheduledPairs = <String>{};
    final allPairs = <(Participant, Participant)>[];

    bool progress = true;
    while (progress) {
      progress = false;
      final sorted = List<Participant>.from(players)
        ..sort((a, b) => (matchesRemaining[b.id] ?? 0).compareTo(matchesRemaining[a.id] ?? 0));

      for (final p1 in sorted) {
        if ((matchesRemaining[p1.id] ?? 0) <= 0) continue;
        final p1Group = playerGroup[p1.id]!;

        final candidates = List<Participant>.from(players
            .where((p2) =>
                playerGroup[p2.id] != p1Group &&
                (matchesRemaining[p2.id] ?? 0) > 0 &&
                !scheduledPairs.contains('${p1.id}_${p2.id}') &&
                !scheduledPairs.contains('${p2.id}_${p1.id}')))
          ..shuffle();

        if (candidates.isNotEmpty) {
          final p2 = candidates.first;
          allPairs.add((p1, p2));
          scheduledPairs.add('${p1.id}_${p2.id}');
          matchesRemaining[p1.id] = (matchesRemaining[p1.id] ?? 0) - 1;
          matchesRemaining[p2.id] = (matchesRemaining[p2.id] ?? 0) - 1;
          progress = true;
          break;
        }
      }
    }

    final matchDuration = category.matchDurationMinutes;
    DateTime startDate = DateTime.now().add(const Duration(days: 1));
    startDate = DateTime(startDate.year, startDate.month, startDate.day, 9, 0);
    final slots = _generateSlots(startDate, numberOfCourts, matchDuration, allPairs.length + 20, existingMatches);
    int slotIndex = 0;

    final matches = <TennisMatch>[];
    for (final (p1, p2) in allPairs) {
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
        round: 'Americano',
        status: 'Preparing',
        matchIndex: matches.length,
        durationMinutes: matchDuration,
        locationId: tournament.locationId,
      ));
    }

    return matches;
  }

  /// Phase 2: Generate one decider match per group (1st vs 2nd in standings).
  Future<List<TennisMatch>> generateGroupDeciders(
    Tournament tournament,
    TournamentCategory category,
  ) async {
    final standings = await getGroupStandings(tournament.id, category.id);

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
    final slots = _generateSlots(startDate, numberOfCourts, matchDuration, standings.length + 10, existingMatches);
    int slotIndex = 0;

    final matches = <TennisMatch>[];
    for (final entry in standings.entries) {
      final groupId = entry.key;
      final sorted = entry.value;
      if (sorted.length < 2) continue;

      final p1s = sorted[0]; // 1st place
      final p2s = sorted[1]; // 2nd place

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
        player1Id: p1s.participantId,
        player1Name: p1s.participantName,
        player1UserIds: p1s.participantUserIds,
        player1AvatarUrls: p1s.participantAvatarUrls,
        player2Id: p2s.participantId,
        player2Name: p2s.participantName,
        player2UserIds: p2s.participantUserIds,
        player2AvatarUrls: p2s.participantAvatarUrls,
        opponentName: p2s.participantName,
        time: matchTime,
        court: courtName,
        round: 'Decider $groupId',
        status: 'Preparing',
        matchIndex: matches.length,
        durationMinutes: matchDuration,
        locationId: tournament.locationId,
      ));
    }

    return matches;
  }

  /// Phase 3: Generate single-elimination playoff from group decider winners.
  Future<List<TennisMatch>> generatePlayoffBracket(
    Tournament tournament,
    TournamentCategory category,
  ) async {
    final allMatches = await _ref.read(matchRepositoryProvider).getMatchesForTournament(tournament.id);
    final deciderMatches = allMatches
        .where((m) => m.categoryId == category.id && m.round.startsWith('Decider'))
        .toList();

    final qualifiedPlayers = <Participant>[];
    for (final match in deciderMatches) {
      if (match.winner == null) continue;
      final isP1Winner = match.winner == match.player1Name;
      final winnerId = isP1Winner ? match.player1Id : match.player2Id;
      if (winnerId == null) continue;
      qualifiedPlayers.add(Participant(
        id: winnerId,
        name: match.winner!,
        categoryId: category.id,
        userIds: isP1Winner ? match.player1UserIds : match.player2UserIds,
        avatarUrls: isP1Winner ? match.player1AvatarUrls : match.player2AvatarUrls,
        status: 'approved',
        joinedAt: DateTime.now(),
      ));
    }

    if (qualifiedPlayers.length < 2) return [];

    int numberOfCourts = 1;
    if (tournament.locationId != null) {
      try {
        final loc = await _ref.read(locationRepositoryProvider).getLocation(tournament.locationId!);
        if (loc != null) numberOfCourts = loc.numberOfCourts;
      } catch (_) {}
    }

    final matchDuration = category.matchDurationMinutes;
    DateTime startDate = DateTime.now().add(const Duration(days: 1));
    startDate = DateTime(startDate.year, startDate.month, startDate.day, 9, 0);
    final slots = _generateSlots(startDate, numberOfCourts, matchDuration, 50, allMatches);
    int slotIndex = 0;

    final matches = <TennisMatch>[];
    var currentPlayers = qualifiedPlayers;
    int round = 1;

    while (currentPlayers.length >= 2) {
      for (int i = 0; i + 1 < currentPlayers.length; i += 2) {
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
          round: 'Playoff R$round',
          status: 'Preparing',
          matchIndex: i ~/ 2,
          durationMinutes: matchDuration,
          locationId: tournament.locationId,
        ));
      }
      // Winners are populated as matches complete; stop after first round generation
      break;
    }

    return matches;
  }

  Future<void> updateStandingsAfterMatch(
    String tournamentId,
    String categoryId,
    String winnerId,
    String loserId,
    int pointsPerWin,
  ) async {
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

    final grouped = <String, List<GroupStanding>>{};
    for (final s in standings) {
      grouped.putIfAbsent(s.groupId, () => []);
      grouped[s.groupId]!.add(s);
    }

    for (final group in grouped.values) {
      group.sort((a, b) {
        final pts = b.points.compareTo(a.points);
        if (pts != 0) return pts;
        final wins = b.wins.compareTo(a.wins);
        if (wins != 0) return wins;
        final sets = (b.setsWon - b.setsLost).compareTo(a.setsWon - a.setsLost);
        if (sets != 0) return sets;
        return (b.gamesWon - b.gamesLost).compareTo(a.gamesWon - a.gamesLost);
      });
    }

    return grouped;
  }

  Future<void> _createGroupStandings(
    Tournament tournament,
    TournamentCategory category,
    Map<String, List<Participant>> groups,
  ) async {
    final batch = _firestore.batch();
    for (final entry in groups.entries) {
      for (final player in entry.value) {
        final standing = GroupStanding(
          id: _uuid.v4(),
          tournamentId: tournament.id,
          categoryId: category.id,
          groupId: entry.key,
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

  List<_MatchSlot> _generateSlots(
    DateTime startDate,
    int numberOfCourts,
    int durationMinutes,
    int countNeeded,
    List<TennisMatch> existingMatches,
  ) {
    final slots = <_MatchSlot>[];
    DateTime current = startDate;
    int added = 0;
    int attempts = 0;
    const maxAttempts = 5000;

    while (added < countNeeded && attempts < maxAttempts) {
      for (int c = 1; c <= numberOfCourts; c++) {
        final candidate = _MatchSlot(current, 'Court $c');
        if (!_isSlotOccupied(candidate, existingMatches, durationMinutes)) {
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

  bool _isSlotOccupied(_MatchSlot slot, List<TennisMatch> existingMatches, int durationMinutes) {
    final slotStart = slot.time;
    final slotEnd = slotStart.add(Duration(minutes: durationMinutes));
    for (final match in existingMatches) {
      if (match.court == slot.court) {
        final matchStart = match.time;
        final matchEnd = matchStart.add(Duration(minutes: match.durationMinutes));
        if (slotStart.isBefore(matchEnd) && slotEnd.isAfter(matchStart)) {
          return true;
        }
      }
    }
    return false;
  }
}
