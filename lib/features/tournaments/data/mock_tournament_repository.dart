import 'package:tennis_tournament/core/utils/mock_data.dart';
import 'package:tennis_tournament/features/tournaments/data/tournament_repository.dart';
import 'package:tennis_tournament/features/tournaments/domain/participant.dart';
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
    // Mock implementation
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<bool> isPlayerRegistered(String tournamentId, String userId) async {
    // Mock implementation
    return false;
  }

  @override
  Future<List<Participant>> getParticipants(String tournamentId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      Participant(
        id: '1',
        name: 'John Doe',
        userId: 'user1',
        status: 'approved',
        joinedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Participant(
        id: '2',
        name: 'Jane Smith',
        userId: 'user2',
        status: 'pending',
        joinedAt: DateTime.now(),
      ),
    ];
  }

  @override
  Future<Participant?> getParticipant(String tournamentId, String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Mock: return pending for user2, approved for user1
    if (userId == 'user1') {
      return Participant(
        id: '1',
        name: 'John Doe',
        userId: 'user1',
        status: 'approved',
        joinedAt: DateTime.now().subtract(const Duration(days: 1)),
      );
    } else if (userId == 'user2') {
      return Participant(
        id: '2',
        name: 'Jane Smith',
        userId: 'user2',
        status: 'pending',
        joinedAt: DateTime.now(),
      );
    }
    return null;
  }

  @override
  Future<void> addParticipant(String tournamentId, Participant participant) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<void> updateParticipantStatus(
    String tournamentId,
    String participantId,
    String status,
  ) async {
    await Future.delayed(const Duration(milliseconds: 500));
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
