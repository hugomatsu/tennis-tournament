import 'package:cloud_firestore/cloud_firestore.dart';
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
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<TennisMatch>> getUpcomingMatches() async {
    // Placeholder: Fetch upcoming matches
    return [];
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
      print('Updating match score for $matchId. Score: $score, Winner: $winnerName');
      await _firestore.runTransaction((transaction) async {
        final matchRef = _firestore.collection('matches').doc(matchId);
        final matchSnapshot = await transaction.get(matchRef);

        if (!matchSnapshot.exists) {
          throw Exception('Match not found');
        }

        final matchData = matchSnapshot.data()!;
        print('Match data loaded: ${matchData.keys.join(', ')}');

        final nextMatchId = matchData['nextMatchId'] as String?;
        
        // Safe cast for matchIndex
        final matchIndexVal = matchData['matchIndex'];
        int matchIndex = 0;
        if (matchIndexVal is int) {
          matchIndex = matchIndexVal;
        } else if (matchIndexVal is String) {
          matchIndex = int.tryParse(matchIndexVal) ?? 0;
        }
        print('Match Index: $matchIndex, Next Match ID: $nextMatchId');

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
            print('Next match found: $nextMatchId');
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
            
            print('Propagating winner $winnerName ($winnerId) to slot ${isPlayer1Slot ? "Player 1" : "Player 2"}');

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
        } else if (nextMatchId != null && nextMatchId.isNotEmpty) {
            print('Next match document does not exist: $nextMatchId');
        }
      });
      print('Transaction completed successfully');
    } catch (e, stack) {
      print('Error in updateMatchScore: $e');
      print(stack);
      rethrow;
    }
  }
}
