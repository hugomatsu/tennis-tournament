import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tennis_tournament/features/players/data/player_repository.dart';
import 'package:tennis_tournament/features/players/domain/player.dart';

class FirestorePlayerRepository implements PlayerRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Future<Player?> getCurrentUser() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (!doc.exists) return null;
      
      final data = doc.data()!;
      return Player(
        id: doc.id,
        name: data['name'] as String? ?? user.displayName ?? 'Player',
        title: data['title'] as String? ?? 'Tennis Enthusiast',
        category: data['category'] as String? ?? 'Unranked',
        playingSince: data['playingSince'] as String? ?? DateTime.now().year.toString(),
        wins: data['wins'] as int? ?? 0,
        losses: data['losses'] as int? ?? 0,
        rank: data['rank'] as int? ?? 0,
        bio: data['bio'] as String? ?? 'No bio yet.',
        avatarUrl: data['avatarUrl'] as String? ?? user.photoURL ?? 'https://via.placeholder.com/150',
        userType: data['userType'] as String? ?? 'player',
        isPremium: data['isPremium'] as bool? ?? false,
        subscriptionStatus: data['subscriptionStatus'] as String? ?? 'none',
        followedMatchIds: List<String>.from(data['followedMatchIds'] ?? []),
        following: List<String>.from(data['following'] ?? []),
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> updateUser(Player player) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No authenticated user');

    await _firestore.collection('users').doc(user.uid).set({
      'name': player.name,
      'title': player.title,
      'category': player.category,
      'playingSince': player.playingSince,
      'bio': player.bio,
      'avatarUrl': player.avatarUrl,
      // Keep existing stats if not updating them here, or update them if passed
      'wins': player.wins,
      'losses': player.losses,
      'rank': player.rank,
      // userType is NOT updated here to prevent self-promotion
      'followedMatchIds': player.followedMatchIds,
      'following': player.following,
    }, SetOptions(merge: true));
  }
  @override
  Future<List<Player>> getPlayersForTournament(String tournamentId) async {
    try {
      // 1. Get participant IDs from the tournament's subcollection
      final participantsSnapshot = await _firestore
          .collection('tournaments')
          .doc(tournamentId)
          .collection('participants')
          .get();

      if (participantsSnapshot.docs.isEmpty) return [];

      final participantIds = participantsSnapshot.docs.map((doc) => doc.id).toList();

      // 2. Fetch user documents for these IDs
      // Firestore 'in' query is limited to 10 items. For simplicity in MVP, we'll fetch individually
      // or use 'where' with chunks if needed. For now, parallel gets.
      final playerFutures = participantIds.map((id) async {
        final doc = await _firestore.collection('users').doc(id).get();
        if (!doc.exists) return null;
        final data = doc.data()!;
        return Player(
          id: doc.id,
          name: data['name'] as String? ?? 'Player',
          title: data['title'] as String? ?? '',
          category: data['category'] as String? ?? '',
          playingSince: data['playingSince'] as String? ?? '',
          wins: data['wins'] as int? ?? 0,
          losses: data['losses'] as int? ?? 0,
          rank: data['rank'] as int? ?? 0,
          bio: data['bio'] as String? ?? '',
          avatarUrl: data['avatarUrl'] as String? ?? 'https://via.placeholder.com/150',
          userType: data['userType'] as String? ?? 'player',
          followedMatchIds: List<String>.from(data['followedMatchIds'] ?? []),
          following: List<String>.from(data['following'] ?? []),
        );
      });

      final players = await Future.wait(playerFutures);
      return players.whereType<Player>().toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<Player>> getAllPlayers() async {
    try {
      final snapshot = await _firestore.collection('users').get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Player(
          id: doc.id,
          name: data['name'] as String? ?? 'Player',
          title: data['title'] as String? ?? '',
          category: data['category'] as String? ?? '',
          playingSince: data['playingSince'] as String? ?? '',
          wins: data['wins'] as int? ?? 0,
          losses: data['losses'] as int? ?? 0,
          rank: data['rank'] as int? ?? 0,
          bio: data['bio'] as String? ?? '',
          avatarUrl: data['avatarUrl'] as String? ?? 'https://via.placeholder.com/150',
          userType: data['userType'] as String? ?? 'player',
          followedMatchIds: List<String>.from(data['followedMatchIds'] ?? []),
          following: List<String>.from(data['following'] ?? []),
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> followPlayer(String currentUserId, String targetUserId) async {
    await _firestore.collection('users').doc(currentUserId).update({
      'following': FieldValue.arrayUnion([targetUserId])
    });
  }

  @override
  Future<void> unfollowPlayer(String currentUserId, String targetUserId) async {
    await _firestore.collection('users').doc(currentUserId).update({
      'following': FieldValue.arrayRemove([targetUserId])
    });
  }

  @override
  Future<void> setPremiumStatus(String userId, bool isPremium) async {
    await _firestore.collection('users').doc(userId).update({
      'isPremium': isPremium,
      'subscriptionStatus': isPremium ? 'active' : 'none',
    });
  }

  @override
  Future<void> cancelSubscription(String userId) async {
    await _firestore.collection('users').doc(userId).update({
      'isPremium': false,
      'subscriptionStatus': 'canceled', // Or 'none'
    });
  }

  @override
  Future<List<Player>> getPlayersByIds(List<String> ids) async {
    if (ids.isEmpty) return [];
    try {
      final futures = ids.map((id) => _firestore.collection('users').doc(id).get());
      final snapshots = await Future.wait(futures);
      
      return snapshots
          .where((doc) => doc.exists)
          .map((doc) {
            final data = doc.data()!;
            return Player(
              id: doc.id,
              name: data['name'] as String? ?? 'Player',
              title: data['title'] as String? ?? '',
              category: data['category'] as String? ?? '',
              playingSince: data['playingSince'] as String? ?? '',
              wins: data['wins'] as int? ?? 0,
              losses: data['losses'] as int? ?? 0,
              rank: data['rank'] as int? ?? 0,
              bio: data['bio'] as String? ?? '',
              avatarUrl: data['avatarUrl'] as String? ?? 'https://via.placeholder.com/150',
              userType: data['userType'] as String? ?? 'player',
              followedMatchIds: List<String>.from(data['followedMatchIds'] ?? []),
              following: List<String>.from(data['following'] ?? []),
            );
          }).toList();
    } catch (e) {
      return [];
    }
  }
  @override
  Future<Player?> getPlayer(String id) async {
    try {
      final doc = await _firestore.collection('users').doc(id).get();
      if (!doc.exists) return null;
      
      final data = doc.data()!;
      return Player(
        id: doc.id,
        name: data['name'] as String? ?? 'Player',
        title: data['title'] as String? ?? '',
        category: data['category'] as String? ?? '',
        playingSince: data['playingSince'] as String? ?? '',
        wins: data['wins'] as int? ?? 0,
        losses: data['losses'] as int? ?? 0,
        rank: data['rank'] as int? ?? 0,
        bio: data['bio'] as String? ?? '',
        avatarUrl: data['avatarUrl'] as String? ?? 'https://via.placeholder.com/150',
        userType: data['userType'] as String? ?? 'player',
        followedMatchIds: List<String>.from(data['followedMatchIds'] ?? []),
        following: List<String>.from(data['following'] ?? []),
        isPremium: data['isPremium'] as bool? ?? false,
        subscriptionStatus: data['subscriptionStatus'] as String? ?? 'none',
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Future<int> getTournamentsParticipatedCount(String userId) async {
    try {
      // Query all tournaments where the user is a participant by checking matches
      // Alternatively, we could track this in a separate field, but for now we'll
      // count tournaments where the user appears in any match
      final matchesSnapshot = await _firestore
          .collection('matches')
          .where('player1UserIds', arrayContains: userId)
          .get();
      
      final matchesSnapshot2 = await _firestore
          .collection('matches')
          .where('player2UserIds', arrayContains: userId)
          .get();
      
      // Get unique tournament IDs from matches
      final tournamentIds = <String>{};
      for (final doc in matchesSnapshot.docs) {
        final tournamentId = doc.data()['tournamentId'] as String?;
        if (tournamentId != null) tournamentIds.add(tournamentId);
      }
      for (final doc in matchesSnapshot2.docs) {
        final tournamentId = doc.data()['tournamentId'] as String?;
        if (tournamentId != null) tournamentIds.add(tournamentId);
      }
      
      return tournamentIds.length;
    } catch (e) {
      return 0;
    }
  }
}
