import 'package:tennis_tournament/core/utils/mock_data.dart';
import 'package:tennis_tournament/features/tournaments/data/tournament_repository.dart';
import 'package:tennis_tournament/features/tournaments/domain/participant.dart';
import 'package:tennis_tournament/features/tournaments/domain/tournament.dart';
import 'package:tennis_tournament/features/tournaments/domain/tournament_category.dart';

class MockTournamentRepository implements TournamentRepository {
  @override
  Future<List<Tournament>> getLiveTournaments({String? category}) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    var tournaments = MockData.liveTournaments.map((data) => _mapToTournament(data)).toList();
    
    if (category != null && category != 'All') {
      tournaments = tournaments.where((t) => t.category == category).toList();
    }
    
    return tournaments;
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
  Future<List<Participant>> getParticipantsForUser(String tournamentId, String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [];
  }

  @override
  Future<void> joinTournament(String tournamentId, String userId, String categoryId) async {
    // Mock implementation
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<void> leaveTournament(String tournamentId, String userId, String categoryId) async {
    // Mock implementation
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<void> updateTournament(Tournament tournament) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<void> deleteTournament(String tournamentId) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<void> addCategory(TournamentCategory category) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<void> updateCategory(TournamentCategory category) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<List<TournamentCategory>> getCategories(String tournamentId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      TournamentCategory(
        id: 'cat1',
        tournamentId: tournamentId,
        name: 'Open',
        type: 'singles',
        description: 'Open category for all players',
      ),
    ];
  }

  @override
  Future<List<Participant>> getParticipants(String tournamentId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      Participant(
        id: '1',
        name: 'John Doe',
        userId: 'user1',
        categoryId: 'cat1',
        status: 'approved',
        joinedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Participant(
        id: '2',
        name: 'Jane Smith',
        userId: 'user2',
        categoryId: 'cat1',
        status: 'pending',
        joinedAt: DateTime.now(),
      ),
    ];
  }

  @override
  Future<bool> isPlayerRegistered(String tournamentId, String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return false;
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
      category: data['category'] as String? ?? 'Open',
    );
  }
}
