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
        'opponentName': match.opponentName,
        'time': match.time.toIso8601String(),
        'court': match.court,
        'round': match.round,
        'status': match.status,
        'score': match.score,
        'winner': match.winner,
      });
    }
    await batch.commit();
  }
}
