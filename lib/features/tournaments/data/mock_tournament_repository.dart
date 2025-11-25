import 'package:tennis_tournament/core/utils/mock_data.dart';
import 'package:tennis_tournament/features/tournaments/data/tournament_repository.dart';
import 'package:tennis_tournament/features/tournaments/domain/tournament.dart';

class MockTournamentRepository implements TournamentRepository {
  @override
  Future<List<Tournament>> getLiveTournaments() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    return MockData.liveTournaments.map((data) => _mapToTournament(data)).toList();
  }

  @override
  Future<Tournament?> getTournament(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final data = MockData.liveTournaments.firstWhere(
      (t) => t['id'] == id,
      orElse: () => {},
    );
    if (data.isEmpty) return null;
    return _mapToTournament(data);
  }

  @override
  Future<void> createTournament(Tournament tournament) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Mock implementation: do nothing
  }

  @override
  Future<void> joinTournament(String tournamentId, String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Mock implementation: do nothing
  }

  @override
  Future<bool> isPlayerRegistered(String tournamentId, String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return false; // Always return false for mock to allow joining
  }

  Tournament _mapToTournament(Map<String, dynamic> data) {
    return Tournament(
      id: data['id'] as String,
      name: data['name'] as String,
      status: data['status'] as String,
      playersCount: data['players'] as int,
      location: data['location'] as String,
      imageUrl: data['image'] as String,
      description: data['description'] as String? ?? '',
      dateRange: data['dates'] as String? ?? '',
    );
  }
}
