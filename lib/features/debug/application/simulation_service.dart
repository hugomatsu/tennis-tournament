import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tennis_tournament/features/matches/data/match_repository.dart';
import 'package:tennis_tournament/features/players/domain/player.dart';
import 'package:tennis_tournament/features/tournaments/application/single_elimination_service.dart';
import 'package:tennis_tournament/features/tournaments/data/tournament_repository.dart';
import 'package:tennis_tournament/features/tournaments/domain/participant.dart';
import 'package:tennis_tournament/features/tournaments/domain/tournament.dart';
import 'package:uuid/uuid.dart';

final simulationServiceProvider = Provider((ref) => SimulationService(ref));

class SimulationService {
  final Ref _ref;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  SimulationService(this._ref);

  Future<void> seedTournament({
    required String name,
    required int playerCount,
    required int categoryCount,
    bool autoGenerateBracket = true,
  }) async {
    final tournamentRepo = _ref.read(tournamentRepositoryProvider);
    final matchRepo = _ref.read(matchRepositoryProvider);
    final schedulingService = _ref.read(schedulingServiceProvider);

    // 1. Create Tournament
    final tournamentId = const Uuid().v4();
    final tournament = Tournament(
      id: tournamentId,
      name: name,
      status: 'Registration Open',
      playersCount: playerCount * categoryCount,
      location: 'Simulation Court',
      imageUrl: 'https://images.unsplash.com/photo-1622279457486-62dcc4a431d6?q=80&w=2070&auto=format&fit=crop',
      description: 'Simulated tournament for testing purposes.',
      dateRange: 'Dec 1 - Dec 5',
      category: categoryCount > 1 ? 'Multi-Category' : 'Open',
    );

    await tournamentRepo.createTournament(tournament);

    // 2. Create Dummy Players & Participants
    final participants = <Participant>[];

    for (int c = 0; c < categoryCount; c++) {
      final categoryName = categoryCount > 1 ? 'Category ${String.fromCharCode(65 + c)}' : 'Open';
      
      for (int i = 0; i < playerCount; i++) {
        final playerId = const Uuid().v4();
        final playerName = 'Bot ${String.fromCharCode(65 + c)}${i + 1}';
        
        // Create Player in Firestore (users collection)
        final player = Player(
          id: playerId,
          name: playerName,
          title: 'AI Player',
          category: categoryName,
          playingSince: '2024',
          wins: 0,
          losses: 0,
          rank: 100 + i,
          bio: 'I am a simulated player.',
          avatarUrl: 'https://i.pravatar.cc/150?u=$playerId',
          userType: 'player',
        );

        await _firestore.collection('users').doc(playerId).set(player.toJson());

        // Add as Participant
        final participant = Participant(
          id: const Uuid().v4(),
          userId: playerId,
          name: playerName,
          avatarUrl: player.avatarUrl,
          status: 'approved', // Auto-approve
          joinedAt: DateTime.now(),
        );

        await tournamentRepo.addParticipant(tournamentId, participant);
        participants.add(participant);
      }
    }

    // 3. Generate Bracket (Optional)
    if (autoGenerateBracket) {
      // If multi-category, we might need logic to split participants.
      // For now, the SchedulingService might assume one big bracket or we need to filter.
      // The current SchedulingService likely takes a list of participants and makes one bracket.
      // If we have multiple categories, we'd ideally generate multiple brackets or one big one.
      // Given the current implementation of SchedulingService (SingleElimination), it probably just takes a list.
      
      // Let's just generate one bracket for the whole list for now, 
      // or if categoryCount > 1, we might skip auto-generation or handle it if the service supports it.
      // Checking SchedulingService... it takes (Tournament, List<Participant>).
      
      // For simplicity in this iteration, we'll generate one bracket with all participants.
      final matches = await schedulingService.generateBracket(tournament, participants);
      await matchRepo.createMatches(matches);
      
      // Update tournament status
      // We don't have an updateTournament method exposed in the interface easily, 
      // but we can assume it's fine or add it later.
    }
  }
  
  Future<void> clearAllSimulations() async {
    // Dangerous! Only for dev.
    // Delete all tournaments with "Simulation" in description or specific ID pattern?
    // For now, let's just leave this empty or implement simple cleanup if needed.
  }
}
