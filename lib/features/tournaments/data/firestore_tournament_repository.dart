import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tennis_tournament/features/tournaments/data/tournament_repository.dart';
import 'package:tennis_tournament/features/tournaments/domain/tournament.dart';

class FirestoreTournamentRepository implements TournamentRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<List<Tournament>> getLiveTournaments() async {
    try {
      final snapshot = await _firestore.collection('tournaments').get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Tournament(
          id: doc.id,
          name: data['name'] as String,
          status: data['status'] as String,
          playersCount: data['playersCount'] as int,
          location: data['location'] as String,
          imageUrl: data['imageUrl'] as String,
          description: data['description'] as String,
          dateRange: data['dateRange'] as String,
        );
      }).toList();
    } catch (e) {
      // Return empty list on error for now, or rethrow
      return [];
    }
  }

  @override
  Future<Tournament?> getTournament(String id) async {
    try {
      final doc = await _firestore.collection('tournaments').doc(id).get();
      if (!doc.exists) return null;
      final data = doc.data()!;
      return Tournament(
        id: doc.id,
        name: data['name'] as String,
        status: data['status'] as String,
        playersCount: data['playersCount'] as int,
        location: data['location'] as String,
        imageUrl: data['imageUrl'] as String,
        description: data['description'] as String,
        dateRange: data['dateRange'] as String,
      );
    } catch (e) {
      return null;
    }
  }
}
