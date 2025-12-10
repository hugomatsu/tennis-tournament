import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tennis_tournament/features/locations/data/location_repository.dart';
import 'package:tennis_tournament/features/locations/domain/location.dart';

class FirestoreLocationRepository implements LocationRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<void> addLocation(TournamentLocation location) async {
    await _firestore
        .collection('locations')
        .doc(location.id)
        .set(location.toJson());
  }

  @override
  Future<void> updateLocation(TournamentLocation location) async {
    await _firestore
        .collection('locations')
        .doc(location.id)
        .update(location.toJson());
  }

  @override
  Future<void> deleteLocation(String locationId) async {
    await _firestore.collection('locations').doc(locationId).delete();
  }

  @override
  Future<List<TournamentLocation>> getLocations() async {
    final snapshot = await _firestore.collection('locations').get();
    return snapshot.docs
        .map((doc) => TournamentLocation.fromJson(doc.data()))
        .toList();
  }

  @override
  Stream<List<TournamentLocation>> watchLocations() {
    return _firestore.collection('locations').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => TournamentLocation.fromJson(doc.data()))
          .toList();
    });
  }

  @override
  Future<TournamentLocation?> getLocation(String id) async {
    final doc = await _firestore.collection('locations').doc(id).get();
    if (!doc.exists) return null;
    return TournamentLocation.fromJson(doc.data()!);
  }
}
