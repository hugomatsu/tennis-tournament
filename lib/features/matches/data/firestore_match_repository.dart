import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tennis_tournament/features/matches/data/match_repository.dart';
import 'package:tennis_tournament/features/matches/domain/match.dart';

class FirestoreMatchRepository implements MatchRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<TennisMatch?> getNextMatch() async {
    try {
      // Query for the next upcoming match for the current user
      // This is a simplified query; real logic would depend on auth user ID
      final snapshot = await _firestore
          .collection('matches')
          .where('status', isEqualTo: 'Scheduled')
          .orderBy('time')
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;

      final doc = snapshot.docs.first;
      final data = doc.data();
      DateTime parsedTime;
      final timeData = data['time'];
      if (timeData is Timestamp) {
        parsedTime = timeData.toDate();
      } else if (timeData is String) {
        parsedTime = DateTime.tryParse(timeData) ?? DateTime.now();
      } else {
        parsedTime = DateTime.now();
      }

      return TennisMatch(
        id: doc.id,
        tournamentId: data['tournamentId'] as String,
        categoryId: data['categoryId'] as String? ?? '',
        tournamentName: data['tournamentName'] as String,
        player1Id: data['player1Id'] as String? ?? '',
        player1Name: data['player1Name'] as String? ?? 'TBD',
        player1AvatarUrls: data['player1AvatarUrls'] != null ? List<String?>.from(data['player1AvatarUrls']) : [],
        player2Id: data['player2Id'] as String?,
        player2Name: data['player2Name'] as String?,
        player2AvatarUrls: data['player2AvatarUrls'] != null ? List<String?>.from(data['player2AvatarUrls']) : [],
        opponentName: data['opponentName'] as String? ?? '',
        time: parsedTime,
        court: data['court'] as String,
        round: data['round'] as String,
        status: data['status'] as String,
        score: data['score'] as String?,
        winner: data['winner'] as String?,
        nextMatchId: data['nextMatchId'] as String?,
        matchIndex: data['matchIndex'] as int? ?? 0,
        player1Cheers: data['player1Cheers'] as int? ?? 0,
        player2Cheers: data['player2Cheers'] as int? ?? 0,
        player1Confirmed: data['player1Confirmed'] as bool? ?? false,
        player2Confirmed: data['player2Confirmed'] as bool? ?? false,
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<TennisMatch>> getLiveTournamentsMatches() async {
    // Placeholder: Fetch matches from live tournaments
    return [];
  }



  @override
  Future<List<TennisMatch>> getMatchesForTournament(String tournamentId) async {
    try {
      final snapshot = await _firestore
          .collection('matches')
          .where('tournamentId', isEqualTo: tournamentId)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        
        DateTime parsedTime;
        final timeData = data['time'];
        if (timeData is Timestamp) {
          parsedTime = timeData.toDate();
        } else if (timeData is String) {
          parsedTime = DateTime.tryParse(timeData) ?? DateTime.now();
        } else {
          parsedTime = DateTime.now();
        }

        return TennisMatch(
          id: doc.id,
          tournamentId: data['tournamentId'] as String,
          categoryId: data['categoryId'] as String? ?? '',
          tournamentName: data['tournamentName'] as String,
          player1Id: data['player1Id'] as String? ?? '',
          player1Name: data['player1Name'] as String? ?? 'TBD',
          player1AvatarUrls: data['player1AvatarUrls'] != null ? List<String?>.from(data['player1AvatarUrls']) : [],
          player2Id: data['player2Id'] as String?,
          player2Name: data['player2Name'] as String?,
          player2AvatarUrls: data['player2AvatarUrls'] != null ? List<String?>.from(data['player2AvatarUrls']) : [],
          opponentName: data['opponentName'] as String? ?? '',
          time: parsedTime,
          court: data['court'] as String,
          round: data['round'] as String,
          status: data['status'] as String,
          score: data['score'] as String?,
          winner: data['winner'] as String?,
          nextMatchId: data['nextMatchId'] as String?,
          matchIndex: data['matchIndex'] as int? ?? 0,
          player1Cheers: data['player1Cheers'] as int? ?? 0,
          player2Cheers: data['player2Cheers'] as int? ?? 0,
          player1Confirmed: data['player1Confirmed'] as bool? ?? false,
          player2Confirmed: data['player2Confirmed'] as bool? ?? false,
          durationMinutes: data['durationMinutes'] as int? ?? 90,
          locationId: data['locationId'] as String?,
        );
      }).toList().cast<TennisMatch>();
    } catch (e) {
      return [];
    }
  }

  @override
  Stream<List<TennisMatch>> watchMatchesForTournament(String tournamentId) {
    return _firestore
        .collection('matches')
        .where('tournamentId', isEqualTo: tournamentId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        
        DateTime parsedTime;
        final timeData = data['time'];
        if (timeData is Timestamp) {
          parsedTime = timeData.toDate();
        } else if (timeData is String) {
          parsedTime = DateTime.tryParse(timeData) ?? DateTime.now();
        } else {
          parsedTime = DateTime.now();
        }

        return TennisMatch(
          id: doc.id,
          tournamentId: data['tournamentId'] as String,
          categoryId: data['categoryId'] as String? ?? '',
          tournamentName: data['tournamentName'] as String,
          player1Id: data['player1Id'] as String? ?? '',
          player1Name: data['player1Name'] as String? ?? 'TBD',
          player1AvatarUrls: data['player1AvatarUrls'] != null ? List<String?>.from(data['player1AvatarUrls']) : [],
          player2Id: data['player2Id'] as String?,
          player2Name: data['player2Name'] as String?,
          player2AvatarUrls: data['player2AvatarUrls'] != null ? List<String?>.from(data['player2AvatarUrls']) : [],
          opponentName: data['opponentName'] as String? ?? '',
          time: parsedTime,
          court: data['court'] as String,
          round: data['round'] as String,
          status: data['status'] as String,
          score: data['score'] as String?,
          winner: data['winner'] as String?,
          nextMatchId: data['nextMatchId'] as String?,
          matchIndex: data['matchIndex'] as int? ?? 0,
          player1Cheers: data['player1Cheers'] as int? ?? 0,
          player2Cheers: data['player2Cheers'] as int? ?? 0,
          player1Confirmed: data['player1Confirmed'] as bool? ?? false,
          player2Confirmed: data['player2Confirmed'] as bool? ?? false,
          durationMinutes: data['durationMinutes'] as int? ?? 90,
          locationId: data['locationId'] as String?,
        );
      }).toList().cast<TennisMatch>();
    });
  }

  @override
  Future<List<TennisMatch>> getUpcomingMatches() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return [];

      final q1 = _firestore
          .collection('matches')
          .where('status', whereIn: ['Scheduled', 'Confirmed', 'Preparing', 'Started', 'Pending'])
          .where('player1UserIds', arrayContains: user.uid)
          .get();

      final q2 = _firestore
          .collection('matches')
          .where('status', whereIn: ['Scheduled', 'Confirmed', 'Preparing', 'Started', 'Pending'])
          .where('player2UserIds', arrayContains: user.uid)
          .get();

      final results = await Future.wait([q1, q2]);
      
      final allDocs = [...results[0].docs, ...results[1].docs];
      final uniqueDocs = {for (var doc in allDocs) doc.id: doc}.values;

      final matches = uniqueDocs.map((doc) => _matchFromData(doc.id, doc.data())).toList();

      matches.sort((a, b) => a.time.compareTo(b.time));
      
      return matches;
    } catch (e) {
      print('Error fetching upcoming matches: $e');
      return [];
    }
  }

  @override
  Stream<List<TennisMatch>> watchUpcomingMatches(List<String> followedMatchIds) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return Stream.value([]);

    return _firestore
        .collection('matches')
        .where('status', whereIn: ['Scheduled', 'Confirmed', 'Preparing', 'Started', 'Pending'])
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => _matchFromData(doc.id, doc.data()))
      .where((match) => 
          match.player1UserIds.contains(user.uid) || 
          match.player2UserIds.contains(user.uid) || 
          followedMatchIds.contains(match.id)
      ).toList()
      ..sort((a, b) => a.time.compareTo(b.time));
    });
  }

  @override
  Future<void> createMatches(List<TennisMatch> matches) async {
    final batch = _firestore.batch();
    for (final match in matches) {
      final docRef = _firestore.collection('matches').doc(match.id);
      batch.set(docRef, {
        'tournamentId': match.tournamentId,
        'categoryId': match.categoryId,
        'tournamentName': match.tournamentName,
        'player1Id': match.player1Id,
        'player1Name': match.player1Name,
        'player1UserIds': match.player1UserIds,
        'player1AvatarUrls': match.player1AvatarUrls,
        'player2Id': match.player2Id,
        'player2Name': match.player2Name,
        'player2UserIds': match.player2UserIds,
        'player2AvatarUrls': match.player2AvatarUrls,
        'opponentName': match.opponentName,
        'time': match.time.toIso8601String(),
        'court': match.court,
        'round': match.round,
        'status': match.status,
        'score': match.score,
        'winner': match.winner,
        'nextMatchId': match.nextMatchId,
        'matchIndex': match.matchIndex,
        'durationMinutes': match.durationMinutes,
        'locationId': match.locationId,
      });
    }
    await batch.commit();
  }

  @override
  Future<void> updateMatch(TennisMatch match) async {
    await _firestore.collection('matches').doc(match.id).update({
      'player1Id': match.player1Id,
      'player1Name': match.player1Name,
      'player1UserIds': match.player1UserIds,
      'player1AvatarUrls': match.player1AvatarUrls,
      'player2Id': match.player2Id,
      'player2Name': match.player2Name,
      'player2UserIds': match.player2UserIds,
      'player2AvatarUrls': match.player2AvatarUrls,
      'status': match.status,
      'score': match.score,
      'winner': match.winner,
      'time': match.time.toIso8601String(),
      'court': match.court,
      'durationMinutes': match.durationMinutes,
      'locationId': match.locationId,
      'player1Justification': match.player1Justification,
      'player2Justification': match.player2Justification,
      'player1Confirmed': match.player1Confirmed,
      'player2Confirmed': match.player2Confirmed,
    });
  }

  @override
  Future<void> updateMatchScore(String matchId, String score, String winnerName, {String resultType = 'normal'}) async {
    String? tournamentId;
    try {
      await _firestore.runTransaction((transaction) async {
        final matchRef = _firestore.collection('matches').doc(matchId);
        final matchSnapshot = await transaction.get(matchRef);

        if (!matchSnapshot.exists) {
          throw Exception('Match not found');
        }

        final matchData = matchSnapshot.data()!;
        tournamentId = matchData['tournamentId'] as String?;

        final nextMatchId = matchData['nextMatchId'] as String?;
        
        // Safe cast for matchIndex
        final matchIndexVal = matchData['matchIndex'];
        int matchIndex = 0;
        if (matchIndexVal is int) {
          matchIndex = matchIndexVal;
        } else if (matchIndexVal is String) {
          matchIndex = int.tryParse(matchIndexVal) ?? 0;
        }

        DocumentSnapshot<Map<String, dynamic>>? nextMatchSnapshot;
        DocumentReference<Map<String, dynamic>>? nextMatchRef;

        if (nextMatchId != null && nextMatchId.isNotEmpty) {
           nextMatchRef = _firestore.collection('matches').doc(nextMatchId);
           nextMatchSnapshot = await transaction.get(nextMatchRef);
        }
        
        transaction.update(matchRef, {
          'score': score,
          'winner': winnerName,
          'status': 'Completed',
          'resultType': resultType,
        });

        if (nextMatchSnapshot != null && nextMatchSnapshot.exists && nextMatchRef != null) {
            // Determine which slot the winner goes to
            // Logic: Even index -> Player 1, Odd index -> Player 2
            final isPlayer1Slot = (matchIndex % 2) == 0;

            String winnerId = '';
            List<String> winnerUserIds = [];
            List<String?> winnerAvatars = [];

            final p1Name = matchData['player1Name'] as String? ?? 'TBD';
            final p1Id = matchData['player1Id'] as String? ?? '';
            final p1UserIds = List<String>.from(matchData['player1UserIds'] ?? []);
            final p1Avatars = List<String?>.from(matchData['player1AvatarUrls'] ?? []);
            
            final p2Id = matchData['player2Id'] as String? ?? '';
            final p2UserIds = List<String>.from(matchData['player2UserIds'] ?? []);
            final p2Avatars = List<String?>.from(matchData['player2AvatarUrls'] ?? []);

            if (winnerName == p1Name) {
              winnerId = p1Id;
              winnerUserIds = p1UserIds;
              winnerAvatars = p1Avatars;
            } else {
              winnerId = p2Id;
              winnerUserIds = p2UserIds;
              winnerAvatars = p2Avatars;
            }
            
            if (isPlayer1Slot) {
              transaction.update(nextMatchRef, {
                'player1Id': winnerId,
                'player1Name': winnerName,
                'player1UserIds': winnerUserIds,
                'player1AvatarUrls': winnerAvatars,
              });
            } else {
              transaction.update(nextMatchRef, {
                'player2Id': winnerId,
                'player2Name': winnerName,
                'player2UserIds': winnerUserIds,
                'player2AvatarUrls': winnerAvatars,
                'opponentName': winnerName, // Legacy field
              });
            }
        }
      });
      
      // After transaction completes, check if all tournament matches are completed
      if (tournamentId != null && tournamentId!.isNotEmpty) {
        await _checkAndCompleteTournament(tournamentId!);
        
        // For Open Tennis group matches, update standings
        final matchDoc = await _firestore.collection('matches').doc(matchId).get();
        final matchData = matchDoc.data();
        if (matchData != null) {
          final round = matchData['round'] as String? ?? '';
          if (round.startsWith('Group') || round.startsWith('Cross') || round == 'Americano') {
            await _updateGroupStandings(
              tournamentId!,
              matchData['categoryId'] as String? ?? '',
              matchData['player1Id'] as String? ?? '',
              matchData['player1Name'] as String? ?? '',
              matchData['player2Id'] as String? ?? '',
              matchData['player2Name'] as String? ?? '',
              winnerName,
              score: matchData['score'] as String? ?? '',
              resultType: matchData['resultType'] as String? ?? 'normal',
            );
          }
          
          // Update winner's victory count in their player profile (only for non-guests)
          await _updatePlayerVictoryCount(matchData, winnerName);
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Update group standings after a group match is completed
  Future<void> _updateGroupStandings(
    String tournamentId,
    String categoryId,
    String player1Id,
    String player1Name,
    String player2Id,
    String player2Name,
    String winnerName, {
    String score = '',
    String resultType = 'normal',
  }) async {
    final standingsRef = _firestore
        .collection('tournaments')
        .doc(tournamentId)
        .collection('standings');

    // Determine winner and loser IDs
    final winnerId = winnerName == player1Name ? player1Id : player2Id;
    final loserId = winnerName == player1Name ? player2Id : player1Id;

    // Get tournament to check scoring mode
    final tournamentDoc = await _firestore.collection('tournaments').doc(tournamentId).get();
    final tournamentData = tournamentDoc.data() ?? {};
    final matchRules = tournamentData['matchRules'] as Map<String, dynamic>? ?? {};
    final scoringMode = matchRules['scoringMode'] as String? ?? 'flat';
    final pointsPerWin = tournamentData['pointsPerWin'] as int? ?? 3;

    int winnerPoints;
    int loserPoints;

    if (scoringMode == 'variable') {
      if (resultType == 'walkover') {
        winnerPoints = (matchRules['pointsWinWO'] as int?) ?? 2;
        loserPoints = (matchRules['pointsLossWO'] as int?) ?? 0;
      } else {
        // Count sets from score string (e.g. "6-4, 7-5" = 2 sets, "6-4, 4-6, 10-7" = 3 sets)
        final sets = score.split(',').where((s) => s.trim().isNotEmpty).length;
        if (sets <= 2) {
          // 2-0 result
          winnerPoints = (matchRules['pointsWin2_0'] as int?) ?? 4;
          loserPoints = (matchRules['pointsLoss0_2'] as int?) ?? 0;
        } else {
          // 2-1 result
          winnerPoints = (matchRules['pointsWin2_1'] as int?) ?? 3;
          loserPoints = (matchRules['pointsLoss1_2'] as int?) ?? 1;
        }
      }
    } else {
      winnerPoints = pointsPerWin;
      loserPoints = 0;
    }

    // Update winner standing
    final winnerQuery = await standingsRef
        .where('categoryId', isEqualTo: categoryId)
        .where('participantId', isEqualTo: winnerId)
        .limit(1)
        .get();

    if (winnerQuery.docs.isNotEmpty) {
      await winnerQuery.docs.first.reference.update({
        'matchesPlayed': FieldValue.increment(1),
        'wins': FieldValue.increment(1),
        'points': FieldValue.increment(winnerPoints),
      });
    }

    // Update loser standing
    final loserQuery = await standingsRef
        .where('categoryId', isEqualTo: categoryId)
        .where('participantId', isEqualTo: loserId)
        .limit(1)
        .get();

    if (loserQuery.docs.isNotEmpty) {
      final loserUpdate = <String, dynamic>{
        'matchesPlayed': FieldValue.increment(1),
        'losses': FieldValue.increment(1),
      };
      if (loserPoints > 0) {
        loserUpdate['points'] = FieldValue.increment(loserPoints);
      }
      await loserQuery.docs.first.reference.update(loserUpdate);
    }
  }

  /// Update the winner player's victory count (only for non-guest players)
  Future<void> _updatePlayerVictoryCount(Map<String, dynamic> matchData, String winnerName) async {
    try {
      // Determine which player won and get their userIds
      final p1Name = matchData['player1Name'] as String? ?? '';
      final p1UserIds = List<String>.from(matchData['player1UserIds'] ?? []);
      final p2UserIds = List<String>.from(matchData['player2UserIds'] ?? []);
      
      List<String> winnerUserIds;
      if (winnerName == p1Name) {
        winnerUserIds = p1UserIds;
      } else {
        winnerUserIds = p2UserIds;
      }
      
      // Update wins for each user associated with the winner (skip guests with no userIds)
      for (final userId in winnerUserIds) {
        if (userId.isEmpty) continue;
        
        // Check if this is a real user (exists in users collection)
        final userDoc = await _firestore.collection('users').doc(userId).get();
        if (userDoc.exists) {
          await userDoc.reference.update({
            'wins': FieldValue.increment(1),
          });
        }
      }
    } catch (e) {
      // Silent fail - victory count update is not critical
      print('Error updating player victory count: $e');
    }
  }

  /// Check if all matches for a tournament are completed and update tournament status
  Future<void> _checkAndCompleteTournament(String tournamentId) async {
    try {
      final matchesSnapshot = await _firestore
          .collection('matches')
          .where('tournamentId', isEqualTo: tournamentId)
          .get();
      
      if (matchesSnapshot.docs.isEmpty) return;
      
      // Check if all matches are completed
      final allCompleted = matchesSnapshot.docs.every((doc) {
        final status = doc.data()['status'] as String?;
        return status == 'Completed' || status == 'Finished';
      });
      
      if (allCompleted) {
        // Update tournament status to Completed
        await _firestore.collection('tournaments').doc(tournamentId).update({
          'status': 'Completed',
        });
      }
    } catch (e) {
      // Silently fail - tournament completion is a nice-to-have, not critical
      print('Error checking tournament completion: $e');
    }
  }

  @override
  Future<void> cheerForMatch(String matchId, String playerId) async {
    final matchRef = _firestore.collection('matches').doc(matchId);
    
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(matchRef);
      if (!snapshot.exists) return;
      
      final data = snapshot.data()!;
      final p1UserIds = List<String>.from(data['player1UserIds'] ?? []);
      final p2UserIds = List<String>.from(data['player2UserIds'] ?? []);

      if (p1UserIds.contains(playerId)) {
        transaction.update(matchRef, {
          'player1Cheers': FieldValue.increment(1),
        });
      } else if (p2UserIds.contains(playerId)) {
        transaction.update(matchRef, {
          'player2Cheers': FieldValue.increment(1),
        });
      }
    });
  }

  @override
  Future<void> confirmMatch(String matchId, String playerId) async {
    final matchRef = _firestore.collection('matches').doc(matchId);
    
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(matchRef);
      if (!snapshot.exists) return;
      
      final data = snapshot.data()!;
      final p1UserIds = List<String>.from(data['player1UserIds'] ?? []);
      final p2UserIds = List<String>.from(data['player2UserIds'] ?? []);

      if (p1UserIds.contains(playerId)) {
        transaction.update(matchRef, {
          'player1Confirmed': true,
        });
      } else if (p2UserIds.contains(playerId)) {
        transaction.update(matchRef, {
          'player2Confirmed': true,
        });
      }
    });
  }

  @override
  Future<void> deleteMatchesForTournament(String tournamentId) async {
    final snapshot = await _firestore
        .collection('matches')
        .where('tournamentId', isEqualTo: tournamentId)
        .get();

    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  @override
  Future<TennisMatch?> getMatch(String matchId) async {
    try {
      final doc = await _firestore.collection('matches').doc(matchId).get();
      if (!doc.exists) return null;
      final data = doc.data()!;
      return _matchFromData(doc.id, data);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<TennisMatch>> getMatchesByIds(List<String> matchIds) async {
    if (matchIds.isEmpty) return [];
    
    // Firestore limited to 10 in 'whereIn', so we should chunk it if needed.
    // For now, let's assume we might have <= 10 or do simple fetching.
    // Actually FieldPath.documentId whereIn is supported.
    // But let's just do individual gets for simplicity and avoiding limitation for now (parallel).
    // Or simpler: just parallel usage.

    try {
        if (matchIds.length <= 10) {
            final snapshot = await _firestore.collection('matches')
              .where(FieldPath.documentId, whereIn: matchIds)
              .get();
            return snapshot.docs.map((d) => _matchFromData(d.id, d.data())).toList();
        } else {
            // Naive chunking
            List<TennisMatch> allMatches = [];
            for (var i = 0; i < matchIds.length; i += 10) {
                 final end = (i + 10 < matchIds.length) ? i + 10 : matchIds.length;
                 final chunk = matchIds.sublist(i, end);
                 final snapshot = await _firestore.collection('matches')
                    .where(FieldPath.documentId, whereIn: chunk)
                    .get();
                 allMatches.addAll(snapshot.docs.map((d) => _matchFromData(d.id, d.data())));
            }
            return allMatches;
        }

    } catch (e) {
      return [];
    }
  }

  @override
  Stream<TennisMatch?> watchMatch(String matchId) {
    return _firestore.collection('matches').doc(matchId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return _matchFromData(doc.id, doc.data()!);
    });
  }

  @override
  Future<void> updateMatchesStatus(List<String> matchIds, String status) async {
    final batch = _firestore.batch();
    for (final id in matchIds) {
      final docRef = _firestore.collection('matches').doc(id);
      batch.update(docRef, {'status': status});
    }
    await batch.commit();
  }

  TennisMatch _matchFromData(String id, Map<String, dynamic> data) {
    DateTime parsedTime;
    final timeData = data['time'];
    if (timeData is Timestamp) {
      parsedTime = timeData.toDate();
    } else if (timeData is String) {
      parsedTime = DateTime.tryParse(timeData) ?? DateTime.now();
    } else {
      parsedTime = DateTime.now();
    }

    return TennisMatch(
      id: id,
      tournamentId: data['tournamentId'] as String,
      categoryId: data['categoryId'] as String? ?? '',
      tournamentName: data['tournamentName'] as String,
      player1Id: data['player1Id'] as String? ?? '',
      player1Name: data['player1Name'] as String? ?? 'TBD',
      player1UserIds: List<String>.from(data['player1UserIds'] ?? []),
      player1AvatarUrls: List<String?>.from(data['player1AvatarUrls'] ?? []),
      player2Id: data['player2Id'] as String?,
      player2Name: data['player2Name'] as String?,
      player2UserIds: List<String>.from(data['player2UserIds'] ?? []),
      player2AvatarUrls: List<String?>.from(data['player2AvatarUrls'] ?? []),
      opponentName: data['opponentName'] as String? ?? '',
      time: parsedTime,
      court: data['court'] as String,
      round: data['round'] as String,
      status: data['status'] as String,
      score: data['score'] as String?,
      winner: data['winner'] as String?,
      nextMatchId: data['nextMatchId'] as String?,
      matchIndex: data['matchIndex'] as int? ?? 0,
      player1Cheers: data['player1Cheers'] as int? ?? 0,
      player2Cheers: data['player2Cheers'] as int? ?? 0,
      player1Confirmed: data['player1Confirmed'] as bool? ?? false,
      player2Confirmed: data['player2Confirmed'] as bool? ?? false,
      durationMinutes: data['durationMinutes'] as int? ?? 90,
      locationId: data['locationId'] as String?,
      player1Justification: data['player1Justification'] as String?,
      player2Justification: data['player2Justification'] as String?,
    );
  }
}
