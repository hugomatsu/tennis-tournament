import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tennis_tournament/features/matches/data/match_repository.dart';
import 'package:tennis_tournament/features/players/domain/player.dart';
import 'package:tennis_tournament/features/tournaments/application/single_elimination_service.dart';
import 'package:tennis_tournament/features/tournaments/data/tournament_repository.dart';
import 'package:tennis_tournament/features/tournaments/domain/participant.dart';
import 'package:tennis_tournament/features/tournaments/domain/tournament.dart';
import 'package:tennis_tournament/features/tournaments/domain/tournament_category.dart';
import 'package:tennis_tournament/features/locations/data/location_repository.dart';
import 'package:tennis_tournament/features/locations/domain/location.dart';
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
    final locationRepo = _ref.read(locationRepositoryProvider);

    // 0. Get or Create Location
    String locationId;
    String locationName;

    final existingLocations = await locationRepo.getLocations();
    if (existingLocations.isNotEmpty) {
      final loc = existingLocations.first;
      locationId = loc.id;
      locationName = loc.name;
    } else {
      locationId = const Uuid().v4();
      locationName = 'Simulation Court';
      await locationRepo.addLocation(TournamentLocation(
        id: locationId,
        name: locationName,
        googleMapsUrl: 'https://maps.google.com',
        description: 'A default court for simulations',
        numberOfCourts: 4,
        imageUrl: 'https://images.unsplash.com/photo-1622279457486-62dcc4a431d6?q=80&w=2070&auto=format&fit=crop',
      ));
    }

    // 1. Create Tournament
    final tournamentId = const Uuid().v4();
    final tournament = Tournament(
      id: tournamentId,
      name: name,
      status: 'Registration Open',
      playersCount: playerCount * categoryCount,
      location: locationName,
      locationId: locationId,
      imageUrl: 'https://images.unsplash.com/photo-1622279457486-62dcc4a431d6?q=80&w=2070&auto=format&fit=crop',
      description: 'Simulated tournament for testing purposes.',
      dateRange: 'Dec 1 - Dec 5',
      category: categoryCount > 1 ? 'Multi-Category' : 'Open',
    );

    await tournamentRepo.createTournament(tournament);

    // 2. Create Categories
    final categoryIds = <String>[];
    if (categoryCount > 1) {
      for (int c = 0; c < categoryCount; c++) {
        final catId = const Uuid().v4();
        categoryIds.add(catId);
        final catName = 'Category ${String.fromCharCode(65 + c)}';
        
        await tournamentRepo.addCategory(TournamentCategory(
          id: catId,
          tournamentId: tournamentId,
          name: catName,
          type: 'singles',
        ));
      }
    } else {
      // Single category "Open"
      final catId = const Uuid().v4();
      categoryIds.add(catId);
      await tournamentRepo.addCategory(TournamentCategory(
        id: catId,
        tournamentId: tournamentId,
        name: 'Open',
        type: 'singles',
      ));
    }

    // 3. Create Dummy Players & Participants
    final participants = <Participant>[];

    for (int c = 0; c < categoryCount; c++) {
      final categoryName = categoryCount > 1 ? 'Category ${String.fromCharCode(65 + c)}' : 'Open';
      final categoryId = categoryIds[c];
      
      final categoryParticipants = <Participant>[];

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
          categoryId: categoryId,
          avatarUrl: player.avatarUrl,
          status: 'approved', // Auto-approve
          joinedAt: DateTime.now(),
        );

        await tournamentRepo.addParticipant(tournamentId, participant);
        participants.add(participant);
        categoryParticipants.add(participant);
      }
      
      // 4. Generate Bracket per Category
      if (autoGenerateBracket) {
        final categoryObj = TournamentCategory(
          id: categoryId,
          tournamentId: tournamentId,
          name: categoryName,
          type: 'singles', 
          matchDurationMinutes: 90, // Default for simulation
        );

        final matches = await schedulingService.generateBracket(tournament, categoryObj, categoryParticipants);
        
        // Assign categoryId to matches
        final matchesWithCategory = matches.map((m) => m.copyWith(categoryId: categoryId)).toList();
        
        await matchRepo.createMatches(matchesWithCategory);
      }
    }
  }
  
  Future<void> clearAllSimulations() async {
    // Dangerous! Only for dev.
    // Delete all tournaments with "Simulation" in description or specific ID pattern?
    // For now, let's just leave this empty or implement simple cleanup if needed.
  }
}
