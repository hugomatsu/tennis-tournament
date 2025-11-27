import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tennis_tournament/features/tournaments/data/tournament_repository.dart';
import 'package:tennis_tournament/features/tournaments/domain/participant.dart';
import 'package:tennis_tournament/features/tournaments/domain/tournament.dart';

class FirestoreTournamentRepository implements TournamentRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<List<Tournament>> getLiveTournaments({String? category}) async {
    try {
      Query query = _firestore.collection('tournaments');
      
      if (category != null && category != 'All') {
        query = query.where('category', isEqualTo: category);
      }
      
      final snapshot = await query.get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Tournament(
          id: doc.id,
          name: data['name'] as String,
          status: data['status'] as String,
          playersCount: data['playersCount'] as int,
          location: data['location'] as String,
          imageUrl: data['imageUrl'] as String,
          description: data['description'] as String,
          dateRange: data['dateRange'] as String,
          category: data['category'] as String? ?? 'Open',
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
        category: data['category'] as String? ?? 'Open',
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
      'category': tournament.category,
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

      // Fetch user details to store in participant doc (denormalization)
      // This is important because we want to list participants without fetching users one by one
      final userDoc = await transaction.get(_firestore.collection('users').doc(userId));
      final userData = userDoc.data();
      final userName = userData?['name'] as String? ?? 'Unknown';
      final userAvatar = userData?['avatarUrl'] as String?;

      transaction.set(participantRef, {
        'id': userId,
        'name': userName,
        'userId': userId,
        'avatarUrl': userAvatar,
        'status': 'pending',
        'joinedAt': FieldValue.serverTimestamp(),
      });

      // Do NOT increment playersCount yet. Only approved players count.
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

  @override
  Future<List<Participant>> getParticipants(String tournamentId) async {
    try {
      final snapshot = await _firestore
          .collection('tournaments')
          .doc(tournamentId)
          .collection('participants')
          .orderBy('joinedAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Participant(
          id: doc.id,
          name: data['name'] as String? ?? 'Unknown',
          userId: data['userId'] as String?,
          avatarUrl: data['avatarUrl'] as String?,
          status: data['status'] as String? ?? 'pending',
          joinedAt: (data['joinedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<Participant?> getParticipant(String tournamentId, String userId) async {
    try {
      final doc = await _firestore
          .collection('tournaments')
          .doc(tournamentId)
          .collection('participants')
          .doc(userId)
          .get();

      if (!doc.exists) return null;

      final data = doc.data()!;
      return Participant(
        id: doc.id,
        name: data['name'] as String? ?? 'Unknown',
        userId: data['userId'] as String?,
        avatarUrl: data['avatarUrl'] as String?,
        status: data['status'] as String? ?? 'pending',
        joinedAt: (data['joinedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> addParticipant(String tournamentId, Participant participant) async {
    final tournamentRef = _firestore.collection('tournaments').doc(tournamentId);
    final participantRef = tournamentRef.collection('participants').doc(participant.id);

    await _firestore.runTransaction((transaction) async {
      transaction.set(participantRef, {
        'id': participant.id,
        'name': participant.name,
        'userId': participant.userId,
        'avatarUrl': participant.avatarUrl,
        'status': participant.status,
        'joinedAt': Timestamp.fromDate(participant.joinedAt),
      });

      if (participant.status == 'approved') {
        transaction.update(tournamentRef, {
          'playersCount': FieldValue.increment(1),
        });
      }
    });
  }

  @override
  Future<void> updateParticipantStatus(
    String tournamentId,
    String participantId,
    String status,
  ) async {
    final tournamentRef = _firestore.collection('tournaments').doc(tournamentId);
    final participantRef = tournamentRef.collection('participants').doc(participantId);

    await _firestore.runTransaction((transaction) async {
      final doc = await transaction.get(participantRef);
      if (!doc.exists) return;

      final currentStatus = doc.data()?['status'] as String? ?? 'pending';
      
      if (currentStatus == status) return;

      transaction.update(participantRef, {'status': status});

      // Update count based on status change
      if (currentStatus != 'approved' && status == 'approved') {
        transaction.update(tournamentRef, {
          'playersCount': FieldValue.increment(1),
        });
      } else if (currentStatus == 'approved' && status != 'approved') {
        transaction.update(tournamentRef, {
          'playersCount': FieldValue.increment(-1),
        });
      }
    });
  }
}
