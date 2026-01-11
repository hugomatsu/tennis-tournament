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
          format: data['format'] as String? ?? 'singles',
          locationId: data['locationId'] as String?,
          ownerId: data['ownerId'] as String?,
          adminIds: List<String>.from(data['adminIds'] ?? []),
          scheduleRules: (data['scheduleRules'] as List<dynamic>?)
              ?.map((e) => DailySchedule.fromJson(e as Map<String, dynamic>))
              .toList() ?? [],
        );
      }).toList();
    } catch (e) {
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
        format: data['format'] as String? ?? 'singles',
        locationId: data['locationId'] as String?,
        ownerId: data['ownerId'] as String?,
        adminIds: List<String>.from(data['adminIds'] ?? []),
        scheduleRules: (data['scheduleRules'] as List<dynamic>?)
            ?.map((e) => DailySchedule.fromJson(e as Map<String, dynamic>))
            .toList() ?? [],
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
      'ownerId': tournament.ownerId,
      'adminIds': tournament.adminIds,
      'imageUrl': tournament.imageUrl,
      'status': tournament.status,
      'description': tournament.description,
      'playersCount': tournament.playersCount,
      'category': tournament.category,
      'format': tournament.format,
      'scheduleRules': tournament.scheduleRules.map((e) => e.toJson()).toList(),
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
      'format': tournament.format,
      'adminIds': tournament.adminIds, // Persist admins
      'scheduleRules': tournament.scheduleRules.map((e) => e.toJson()).toList(),
    });
  }

  @override
  Future<void> deleteTournament(String tournamentId) async {
    final ref = _firestore.collection('tournaments').doc(tournamentId);
    
    // Naively delete subcollections? Firestore doesn't support recursive delete from client easily.
    // For now we just delete the document, or we'd rely on a Cloud Function.
    // Let's at least delete what we can or just the main doc.
    await ref.delete();
  }

  @override
  Future<int> getUserTournamentCount(String userId) async {
    final snapshot = await _firestore
        .collection('tournaments')
        .where('ownerId', isEqualTo: userId)
        .count()
        .get();
    return snapshot.count ?? 0;
  }

  @override
  Future<List<Tournament>> getTournamentsForUser(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('tournaments')
          .where(Filter.or(
            Filter('ownerId', isEqualTo: userId),
            Filter('adminIds', arrayContains: userId),
          ))
          .get();

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
          category: data['category'] as String? ?? 'Open',
          format: data['format'] as String? ?? 'singles',
          locationId: data['locationId'] as String?,
          ownerId: data['ownerId'] as String?,
          adminIds: List<String>.from(data['adminIds'] ?? []),
          scheduleRules: (data['scheduleRules'] as List<dynamic>?)
              ?.map((e) => DailySchedule.fromJson(e as Map<String, dynamic>))
              .toList() ?? [],
        );
      }).toList();
    } catch (e) {
      return [];
    }
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
          'matchDurationMinutes': category.matchDurationMinutes,
          'description': category.description,
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
          'matchDurationMinutes': category.matchDurationMinutes,
          'description': category.description,
        });
  }

  @override
  Future<List<TournamentCategory>> getCategories(String tournamentId) async {
    try {
      final snapshot = await _firestore
          .collection('tournaments')
          .doc(tournamentId)
          .collection('categories')
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return TournamentCategory(
          id: doc.id,
          tournamentId: tournamentId,
          name: data['name'] as String,
          type: data['type'] as String? ?? 'singles', 
          matchDurationMinutes: data['matchDurationMinutes'] as int? ?? 90,
          description: data['description'] as String? ?? '',
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<Participant>> getParticipantsForUser(String tournamentId, String userId) async {
    try {
      final snapshot = await _firestore
          .collection('tournaments')
          .doc(tournamentId)
          .collection('participants')
          .where('userIds', arrayContains: userId)
          .get();

      return snapshot.docs.map((doc) => _mapParticipant(doc)).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> joinTournament(String tournamentId, List<String> userIds, String categoryId) async {
    if (userIds.isEmpty) throw Exception('No users provided');

    final tournamentRef = _firestore.collection('tournaments').doc(tournamentId);
    
    // Sort IDs to ensure consistent ID for the same set of players
    final sortedIds = List<String>.from(userIds)..sort();
    final participantId = '${sortedIds.join('_')}_$categoryId';
    
    final participantRef = tournamentRef.collection('participants').doc(participantId);

    await _firestore.runTransaction((transaction) async {
      final participantDoc = await transaction.get(participantRef);
      if (participantDoc.exists) {
        throw Exception('Team already registered for this category');
      }

      // Fetch user details for all members
      final List<String> names = [];
      final List<String?> avatars = [];

      for (final uid in sortedIds) {
         final userDoc = await transaction.get(_firestore.collection('users').doc(uid));
         if (!userDoc.exists) throw Exception('User $uid not found');
         final userData = userDoc.data()!;
         names.add(userData['name'] as String? ?? 'Unknown');
         avatars.add(userData['avatarUrl'] as String?);
      }

      final teamName = names.join(' & ');

      transaction.set(participantRef, {
        'id': participantId,
        'name': teamName,
        'userIds': sortedIds,
        'avatarUrls': avatars,
        'status': 'pending',
        'categoryId': categoryId,
        'joinedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  @override
  Future<void> leaveTournament(String tournamentId, String userId, String categoryId) async {
    final tournamentRef = _firestore.collection('tournaments').doc(tournamentId);
    
    // We need to find the participant document where this user is involved in this category
    // Logic: find participant in this category that contains this userId
    
    final query = await _firestore
        .collection('tournaments')
        .doc(tournamentId)
        .collection('participants')
        .where('categoryId', isEqualTo: categoryId)
        .where('userIds', arrayContains: userId)
        .limit(1)
        .get();

    if (query.docs.isEmpty) return;

    final participantDoc = query.docs.first;
    final participantRef = participantDoc.reference;

    await _firestore.runTransaction((transaction) async {
      final pDoc = await transaction.get(participantRef);
      if (!pDoc.exists) return;

      final status = pDoc.data()?['status'] as String? ?? 'pending';

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
        .where('userIds', arrayContains: userId)
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

      return snapshot.docs.map((doc) => _mapParticipant(doc)).toList();
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
        'userIds': participant.userIds,
        'avatarUrls': participant.avatarUrls,
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
  
  Participant _mapParticipant(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Participant(
      id: doc.id,
      name: data['name'] as String? ?? 'Unknown',
      userIds: List<String>.from(data['userIds'] ?? []),
      avatarUrls: List<String?>.from(data['avatarUrls'] ?? []),
      categoryId: data['categoryId'] as String? ?? '',
      status: data['status'] as String? ?? 'pending',
      joinedAt: (data['joinedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  @override
  Future<void> updateParticipantStatus(
    String tournamentId,
    String participantId,
    String status,
  ) async {
      // ... (Implementation remains same, just logic update)
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
