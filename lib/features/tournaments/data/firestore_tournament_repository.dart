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

  @override
  Future<void> createTournament(Tournament tournament) async {
    await _firestore.collection('tournaments').doc(tournament.id).set({
      'name': tournament.name,
      'dateRange': tournament.dateRange,
      'location': tournament.location,
      'imageUrl': tournament.imageUrl,
      'status': tournament.status,
      'description': tournament.description,
      'playersCount': tournament.playersCount,
    });
  }

  @override
  Future<void> joinTournament(String tournamentId, String userId) async {
    final tournamentRef = _firestore.collection('tournaments').doc(tournamentId);
    final participantRef = tournamentRef.collection('participants').doc(userId);

    await _firestore.runTransaction((transaction) async {
      final participantDoc = await transaction.get(participantRef);
      if (participantDoc.exists) {
        throw Exception('User already registered');
      }

      transaction.set(participantRef, {
        'joinedAt': FieldValue.serverTimestamp(),
      });

      transaction.update(tournamentRef, {
        'playersCount': FieldValue.increment(1),
      });
    });
  }

  @override
  Future<bool> isPlayerRegistered(String tournamentId, String userId) async {
    final doc = await _firestore
        .collection('tournaments')
        .doc(tournamentId)
        .collection('participants')
        .doc(userId)
        .get();
    return doc.exists;
  }
}
