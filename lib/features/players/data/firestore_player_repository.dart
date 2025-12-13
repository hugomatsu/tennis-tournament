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
        followedMatchIds: List<String>.from(data['followedMatchIds'] ?? []),
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
        );
      });

      final players = await Future.wait(playerFutures);
      return players.whereType<Player>().toList();
    } catch (e) {
      return [];
    }
  }
}
