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
        tournamentName: data['tournamentName'] as String,
        player1Id: data['player1Id'] as String? ?? '',
        player1Name: data['player1Name'] as String? ?? 'TBD',
        player1AvatarUrl: data['player1AvatarUrl'] as String?,
        player2Id: data['player2Id'] as String?,
        player2Name: data['player2Name'] as String?,
        player2AvatarUrl: data['player2AvatarUrl'] as String?,
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
          tournamentName: data['tournamentName'] as String,
          player1Id: data['player1Id'] as String? ?? '',
          player1Name: data['player1Name'] as String? ?? 'TBD',
          player1AvatarUrl: data['player1AvatarUrl'] as String?,
          player2Id: data['player2Id'] as String?,
          player2Name: data['player2Name'] as String?,
          player2AvatarUrl: data['player2AvatarUrl'] as String?,
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
      }).toList();
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
          tournamentName: data['tournamentName'] as String,
          player1Id: data['player1Id'] as String? ?? '',
          player1Name: data['player1Name'] as String? ?? 'TBD',
          player1AvatarUrl: data['player1AvatarUrl'] as String?,
          player2Id: data['player2Id'] as String?,
          player2Name: data['player2Name'] as String?,
          player2AvatarUrl: data['player2AvatarUrl'] as String?,
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
      }).toList();
    });
  }

  @override
  Future<List<TennisMatch>> getUpcomingMatches() async {
    try {
      // Note: This requires the current user ID. 
      // In a real app, we'd inject the AuthRepository or UserProvider.
      // For now, we'll assume we can get it from FirebaseAuth directly since this is a Firestore repo.
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return [];

      // Firestore doesn't support logical OR in queries easily for this case (player1 == me OR player2 == me)
      // We have to do two queries and merge, OR rely on a 'participants' array field in the match document.
      // Since we didn't add a 'participants' array, we'll do two queries.
      
      final q1 = _firestore
          .collection('matches')
          .where('status', isEqualTo: 'Scheduled')
          .where('player1Id', isEqualTo: user.uid)
          .get();

      final q2 = _firestore
          .collection('matches')
          .where('status', isEqualTo: 'Scheduled')
          .where('player2Id', isEqualTo: user.uid)
          .get();

      final results = await Future.wait([q1, q2]);
      
      final allDocs = [...results[0].docs, ...results[1].docs];
      
      // Deduplicate by ID just in case (though unlikely with this logic)
      final uniqueDocs = {for (var doc in allDocs) doc.id: doc}.values;

      final matches = uniqueDocs.map((doc) {
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
          tournamentName: data['tournamentName'] as String,
          player1Id: data['player1Id'] as String? ?? '',
          player1Name: data['player1Name'] as String? ?? 'TBD',
          player1AvatarUrl: data['player1AvatarUrl'] as String?,
          player2Id: data['player2Id'] as String?,
          player2Name: data['player2Name'] as String?,
          player2AvatarUrl: data['player2AvatarUrl'] as String?,
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
      }).toList();

      // Sort by time locally since we merged results
      matches.sort((a, b) => a.time.compareTo(b.time));
      
      return matches;
    } catch (e) {
      print('Error fetching upcoming matches: $e');
      return [];
    }
  }

  @override
  Stream<List<TennisMatch>> watchUpcomingMatches() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return Stream.value([]);

    return _firestore
        .collection('matches')
        .where('status', isEqualTo: 'Scheduled')
        .snapshots()
        .map((snapshot) {
      final matches = snapshot.docs.map((doc) {
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
          tournamentName: data['tournamentName'] as String,
          player1Id: data['player1Id'] as String? ?? '',
          player1Name: data['player1Name'] as String? ?? 'TBD',
          player1AvatarUrl: data['player1AvatarUrl'] as String?,
          player2Id: data['player2Id'] as String?,
          player2Name: data['player2Name'] as String?,
          player2AvatarUrl: data['player2AvatarUrl'] as String?,
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
      }).where((match) => match.player1Id == user.uid || match.player2Id == user.uid).toList();
      
      matches.sort((a, b) => a.time.compareTo(b.time));
      return matches;
    });
  }

  @override
  Future<void> createMatches(List<TennisMatch> matches) async {
    final batch = _firestore.batch();
    for (final match in matches) {
      final docRef = _firestore.collection('matches').doc(match.id);
      batch.set(docRef, {
        'tournamentId': match.tournamentId,
        'tournamentName': match.tournamentName,
        'player1Id': match.player1Id,
        'player1Name': match.player1Name,
        'player1AvatarUrl': match.player1AvatarUrl,
        'player2Id': match.player2Id,
        'player2Name': match.player2Name,
        'player2AvatarUrl': match.player2AvatarUrl,
        'opponentName': match.opponentName,
        'time': match.time.toIso8601String(),
        'court': match.court,
        'round': match.round,
        'status': match.status,
        'score': match.score,
        'winner': match.winner,
        'nextMatchId': match.nextMatchId,
        'matchIndex': match.matchIndex,
      });
    }
    await batch.commit();
  }

  @override
  Future<void> updateMatch(TennisMatch match) async {
    await _firestore.collection('matches').doc(match.id).update({
      'player1Id': match.player1Id,
      'player1Name': match.player1Name,
      'player1AvatarUrl': match.player1AvatarUrl,
      'player2Id': match.player2Id,
      'player2Name': match.player2Name,
      'player2AvatarUrl': match.player2AvatarUrl,
      'status': match.status,
      'score': match.score,
      'winner': match.winner,
    });
  }

  @override
  Future<void> updateMatchScore(String matchId, String score, String winnerName) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final matchRef = _firestore.collection('matches').doc(matchId);
        final matchSnapshot = await transaction.get(matchRef);

        if (!matchSnapshot.exists) {
          throw Exception('Match not found');
        }

        final matchData = matchSnapshot.data()!;

        final nextMatchId = matchData['nextMatchId'] as String?;
        
        // Safe cast for matchIndex
        final matchIndexVal = matchData['matchIndex'];
        int matchIndex = 0;
        if (matchIndexVal is int) {
          matchIndex = matchIndexVal;
        } else if (matchIndexVal is String) {
          matchIndex = int.tryParse(matchIndexVal) ?? 0;
        }

        // PREPARE READS FIRST
        DocumentSnapshot<Map<String, dynamic>>? nextMatchSnapshot;
        DocumentReference<Map<String, dynamic>>? nextMatchRef;

        if (nextMatchId != null && nextMatchId.isNotEmpty) {
           nextMatchRef = _firestore.collection('matches').doc(nextMatchId);
           nextMatchSnapshot = await transaction.get(nextMatchRef);
        }
        
        // NOW PERFORM WRITES
        
        // Update current match
        transaction.update(matchRef, {
          'score': score,
          'winner': winnerName,
          'status': 'Completed',
        });

        // Propagate to next match if it exists and was read successfully
        if (nextMatchSnapshot != null && nextMatchSnapshot.exists && nextMatchRef != null) {
            // Determine which slot the winner goes to
            // Logic: Even index -> Player 1, Odd index -> Player 2
            final isPlayer1Slot = (matchIndex % 2) == 0;

            // We need the winner's full details. 
            // Since we only passed winnerName, we should get the ID and Avatar from the current match data.
            String winnerId = '';
            String? winnerAvatar;

            final p1Name = matchData['player1Name'] as String? ?? 'TBD';
            final p1Id = matchData['player1Id'] as String? ?? '';
            final p1Avatar = matchData['player1AvatarUrl'] as String?;
            
            final p2Id = matchData['player2Id'] as String? ?? '';
            final p2Avatar = matchData['player2AvatarUrl'] as String?;

            if (winnerName == p1Name) {
              winnerId = p1Id;
              winnerAvatar = p1Avatar;
            } else {
              winnerId = p2Id;
              winnerAvatar = p2Avatar;
            }
            
            if (isPlayer1Slot) {
              transaction.update(nextMatchRef, {
                'player1Id': winnerId,
                'player1Name': winnerName,
                'player1AvatarUrl': winnerAvatar,
              });
            } else {
              transaction.update(nextMatchRef, {
                'player2Id': winnerId,
                'player2Name': winnerName,
                'player2AvatarUrl': winnerAvatar,
                'opponentName': winnerName, // Legacy field
              });
            }
        }
      });
    } catch (e) {
      rethrow;
    }
  }
  @override
  Future<void> cheerForMatch(String matchId, String playerId) async {
    final matchRef = _firestore.collection('matches').doc(matchId);
    
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(matchRef);
      if (!snapshot.exists) return;
      
      final data = snapshot.data()!;
      if (data['player1Id'] == playerId) {
        transaction.update(matchRef, {
          'player1Cheers': FieldValue.increment(1),
        });
      } else if (data['player2Id'] == playerId) {
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
      if (data['player1Id'] == playerId) {
        transaction.update(matchRef, {
          'player1Confirmed': true,
        });
      } else if (data['player2Id'] == playerId) {
        transaction.update(matchRef, {
          'player2Confirmed': true,
        });
      }
    });
  }
}
