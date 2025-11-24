import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tennis_tournament/features/players/data/player_repository.dart';
import 'package:tennis_tournament/features/players/domain/player.dart';

class FirestorePlayerRepository implements PlayerRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<Player?> getCurrentUser() async {
    try {
      // In a real app, we'd get the ID from FirebaseAuth
      // For now, we'll try to fetch a hardcoded test user or fail gracefully
      final doc = await _firestore.collection('users').doc('current_user').get();
      if (!doc.exists) return null;
      
      final data = doc.data()!;
      return Player(
        id: doc.id,
        name: data['name'] as String,
        title: data['title'] as String,
        category: data['category'] as String,
        playingSince: data['playingSince'] as String,
        wins: data['wins'] as int,
        losses: data['losses'] as int,
        rank: data['rank'] as int,
        bio: data['bio'] as String,
        avatarUrl: data['avatarUrl'] as String,
      );
    } catch (e) {
      return null;
    }
  }
}
