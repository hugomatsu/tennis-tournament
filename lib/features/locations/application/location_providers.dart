import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tennis_tournament/features/locations/data/location_repository.dart';
import 'package:tennis_tournament/features/locations/domain/location.dart';

final locationsProvider = StreamProvider<List<TournamentLocation>>((ref) {
  return ref.watch(locationRepositoryProvider).watchLocations();
});
