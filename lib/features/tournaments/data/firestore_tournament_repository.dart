import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tennis_tournament/features/tournaments/data/tournament_repository.dart';
import 'package:tennis_tournament/features/tournaments/domain/participant.dart';
import 'package:tennis_tournament/features/tournaments/domain/tournament.dart';
import 'package:tennis_tournament/features/tournaments/domain/tournament_category.dart';

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
          locationId: data['locationId'] as String?,
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
        locationId: data['locationId'] as String?,
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
      'locationId': tournament.locationId,
      'imageUrl': tournament.imageUrl,
      'status': tournament.status,
      'description': tournament.description,
      'playersCount': tournament.playersCount,
      'category': tournament.category,
    });
  }

  @override
  Future<void> updateTournament(Tournament tournament) async {
    await _firestore.collection('tournaments').doc(tournament.id).update({
      'name': tournament.name,
      'dateRange': tournament.dateRange,
      'location': tournament.location,
      'locationId': tournament.locationId,
      'imageUrl': tournament.imageUrl,
      'description': tournament.description,
      // 'status': tournament.status, // Status might be handled separately
    });
  }

  @override
  Future<void> deleteTournament(String tournamentId) async {
    final tournamentRef = _firestore.collection('tournaments').doc(tournamentId);

    // Delete participants subcollection
    final participantsSnapshot = await tournamentRef.collection('participants').get();
    for (final doc in participantsSnapshot.docs) {
      await doc.reference.delete();
    }

    // Delete categories subcollection
    final categoriesSnapshot = await tournamentRef.collection('categories').get();
    for (final doc in categoriesSnapshot.docs) {
      await doc.reference.delete();
    }

    // Delete matches linked to this tournament
    final matchesSnapshot = await _firestore
        .collection('matches')
        .where('tournamentId', isEqualTo: tournamentId)
        .get();
    
    final batch = _firestore.batch();
    for (final doc in matchesSnapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();

    // Finally delete tournament
    await tournamentRef.delete();
  }

  @override
  Future<void> addCategory(TournamentCategory category) async {
    await _firestore
        .collection('tournaments')
        .doc(category.tournamentId)
        .collection('categories')
        .doc(category.id)
        .set({
      'id': category.id,
      'tournamentId': category.tournamentId,
      'name': category.name,
      'type': category.type,
      'description': category.description,
      'description': category.description,
      'format': category.format,
      'matchDurationMinutes': category.matchDurationMinutes,
    });
  }

  @override
  Future<void> updateCategory(TournamentCategory category) async {
    await _firestore
        .collection('tournaments')
        .doc(category.tournamentId)
        .collection('categories')
        .doc(category.id)
        .update({
      'name': category.name,
      'type': category.type,
      'description': category.description,
      'format': category.format,
      'matchDurationMinutes': category.matchDurationMinutes,
    });
  }

  @override
  Future<List<TournamentCategory>> getCategories(String tournamentId) async {
    final snapshot = await _firestore
        .collection('tournaments')
        .doc(tournamentId)
        .collection('categories')
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return TournamentCategory(
        id: data['id'] as String,
        tournamentId: data['tournamentId'] as String,
        name: data['name'] as String,
        type: data['type'] as String,
        description: data['description'] as String? ?? '',
        format: data['format'] as String? ?? 'round_robin',
        matchDurationMinutes: data['matchDurationMinutes'] as int? ?? 90,
      );
    }).toList();
  }

  @override
  Future<List<Participant>> getParticipantsForUser(String tournamentId, String userId) async {
    try {
      final snapshot = await _firestore
          .collection('tournaments')
          .doc(tournamentId)
          .collection('participants')
          .where('userId', isEqualTo: userId)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Participant(
          id: doc.id,
          name: data['name'] as String? ?? 'Unknown',
          userId: data['userId'] as String?,
          avatarUrl: data['avatarUrl'] as String?,
          categoryId: data['categoryId'] as String? ?? '',
          status: data['status'] as String? ?? 'pending',
          joinedAt: (data['joinedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> joinTournament(String tournamentId, String userId, String categoryId) async {
    final tournamentRef = _firestore.collection('tournaments').doc(tournamentId);
    // Use composite ID to allow multiple registrations per user (one per category)
    final participantId = '${userId}_$categoryId';
    final participantRef = tournamentRef.collection('participants').doc(participantId);

    await _firestore.runTransaction((transaction) async {
      final participantDoc = await transaction.get(participantRef);
      if (participantDoc.exists) {
        throw Exception('User already registered for this category');
      }

      // Fetch user details to store in participant doc (denormalization)
      final userDoc = await transaction.get(_firestore.collection('users').doc(userId));
      final userData = userDoc.data();
      final userName = userData?['name'] as String? ?? 'Unknown';
      final userAvatar = userData?['avatarUrl'] as String?;

      transaction.set(participantRef, {
        'id': participantId,
        'name': userName,
        'userId': userId,
        'avatarUrl': userAvatar,
        'status': 'pending',
        'categoryId': categoryId,
        'joinedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  @override
  Future<void> leaveTournament(String tournamentId, String userId, String categoryId) async {
    final tournamentRef = _firestore.collection('tournaments').doc(tournamentId);
    final participantId = '${userId}_$categoryId';
    final participantRef = tournamentRef.collection('participants').doc(participantId);

    await _firestore.runTransaction((transaction) async {
      final participantDoc = await transaction.get(participantRef);
      if (!participantDoc.exists) {
        return; // Already left or never joined
      }

      final status = participantDoc.data()?['status'] as String? ?? 'pending';

      transaction.delete(participantRef);

      // Decrement count if they were approved
      if (status == 'approved') {
        transaction.update(tournamentRef, {
          'playersCount': FieldValue.increment(-1),
        });
      }
    });
  }

  @override
  Future<bool> isPlayerRegistered(String tournamentId, String userId) async {
    final snapshot = await _firestore
        .collection('tournaments')
        .doc(tournamentId)
        .collection('participants')
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();
    return snapshot.docs.isNotEmpty;
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
          categoryId: data['categoryId'] as String? ?? '',
          status: data['status'] as String? ?? 'pending',
          joinedAt: (data['joinedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        );
      }).toList();
    } catch (e) {
      return [];
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
        'categoryId': participant.categoryId,
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
