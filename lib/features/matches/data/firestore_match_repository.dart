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
      return TennisMatch(
        id: doc.id,
        tournamentId: data['tournamentId'] as String,
        tournamentName: data['tournamentName'] as String,
        opponentName: data['opponentName'] as String,
        time: (data['time'] as Timestamp).toDate(),
        court: data['court'] as String,
        round: data['round'] as String,
        status: data['status'] as String,
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<TennisMatch>> getMySchedule() async {
    try {
      final snapshot = await _firestore
          .collection('matches')
          .orderBy('time')
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return TennisMatch(
          id: doc.id,
          tournamentId: data['tournamentId'] as String,
          tournamentName: data['tournamentName'] as String,
          opponentName: data['opponentName'] as String,
          time: (data['time'] as Timestamp).toDate(),
          court: data['court'] as String,
          round: data['round'] as String,
          status: data['status'] as String,
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getBracket(String tournamentId) async {
    // Bracket logic is complex in Firestore, typically stored as a JSON blob or subcollection
    // Returning empty for now as placeholder
    return [];
  }
}
