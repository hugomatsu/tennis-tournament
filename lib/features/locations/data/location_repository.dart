import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tennis_tournament/features/locations/data/firestore_location_repository.dart';
import 'package:tennis_tournament/features/locations/domain/location.dart';

abstract class LocationRepository {
  Future<void> addLocation(TournamentLocation location);
  Future<void> updateLocation(TournamentLocation location);
  Future<void> deleteLocation(String locationId);
  Future<List<TournamentLocation>> getLocations();
  Stream<List<TournamentLocation>> watchLocations();
  Future<TournamentLocation?> getLocation(String id);
}

final locationRepositoryProvider = Provider<LocationRepository>((ref) {
  return FirestoreLocationRepository();
});
