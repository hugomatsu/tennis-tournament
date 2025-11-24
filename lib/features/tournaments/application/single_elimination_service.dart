import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tennis_tournament/features/matches/domain/match.dart';
import 'package:tennis_tournament/features/players/domain/player.dart';
import 'package:tennis_tournament/features/tournaments/domain/scheduling_service.dart';
import 'package:tennis_tournament/features/tournaments/domain/tournament.dart';
import 'package:uuid/uuid.dart';

final schedulingServiceProvider = Provider<SchedulingService>((ref) {
  return SingleEliminationService();
});

class SingleEliminationService implements SchedulingService {
  final _uuid = const Uuid();

  @override
  Future<List<TennisMatch>> generateBracket(
    Tournament tournament,
    List<Player> players,
  ) async {
    if (players.length < 2) return [];

    // 1. Shuffle players (random seeding for now)
    final shuffledPlayers = List<Player>.from(players)..shuffle();

    // 2. Calculate bracket size and byes
    final n = shuffledPlayers.length;
    final bracketSize = _nextPowerOfTwo(n);
    final byesCount = bracketSize - n;

    final matches = <TennisMatch>[];
    
    // We need to pair players. 
    // In a standard bracket of size P, we have P/2 matches in the first round (some might be byes).
    // The number of actual matches to be played in Round 1 is (N - Byes) / 2.
    // Wait, let's use the standard array-based tree approach.
    // Positions 0 to (bracketSize/2 - 1) are the matches.
    
    // Let's distribute byes. Usually top seeds get byes.
    // Since we shuffled, let's just say the first 'byesCount' players get byes.
    // But we need to place them in the bracket such that they meet later.
    // For simplicity in this MVP:
    // We will generate matches for Round 1.
    // A "Match" in our system is a database entity.
    
    // Approach:
    // Total slots in Round 1 = bracketSize.
    // We have N players.
    // We pair them up.
    // The first (N - byesCount) players play in the first round? No.
    
    // Let's look at the structure:
    // Round 1 has 'bracketSize / 2' potential matches.
    // We have 'byesCount' byes.
    // So we have 'bracketSize / 2 - byesCount' matches that are "Player vs Bye" (Auto advance).
    // And '(n - (bracketSize / 2 - byesCount) * 1) / 2' ... this math is getting messy.
    
    // Simpler way:
    // Number of matches in Round 1 = bracketSize / 2.
    // We fill these matches with players.
    // Players with indices [0, 1] go to Match 1.
    // Players with indices [2, 3] go to Match 2.
    // ...
    // If we run out of players (because of byes), the remaining spot is a "Bye".
    
    // But we need to distribute byes evenly? Or just fill from top?
    // Standard: Byes are usually placed at the top and bottom of the bracket.
    // For MVP: Fill players into slots 0 to N-1. Slots N to bracketSize-1 are empty (Byes).
    // Match i pairs Slot i and Slot (bracketSize - 1 - i)? No, that's folding.
    // Match i pairs Slot 2*i and Slot 2*i + 1.
    
    // Let's place Byes in the second slot of the pair if possible.
    // Actually, let's just take the list of players, pad it with "Bye" placeholders until size is bracketSize.
    // Then pair (0,1), (2,3), etc.
    // BUT, we want the byes to be distributed so we don't have a whole half of the bracket empty.
    // A common simple seeding for unseeded tournaments:
    // Just pair them up. If odd number, one gets a bye.
    // But for a full bracket, we need to be careful.
    
    // Correct Random Bye placement:
    // We have 'bracketSize' slots.
    // We have 'byesCount' byes.
    // We have 'n' players.
    // We randomly assign 'byesCount' slots to be BYES.
    // The rest 'n' slots are filled with the players.
    // BUT, a match cannot be BYE vs BYE.
    // So, we iterate through the matches (bracketSize / 2).
    // For each match, we can have at most 1 Bye.
    // We have 'byesCount' byes to distribute among 'bracketSize / 2' matches.
    // Since 'byesCount' < 'bracketSize / 2' (unless N < bracketSize/2 which is impossible as bracketSize is next power of 2),
    // we can just assign one bye to each of the first 'byesCount' matches.
    
    final totalRound1Matches = bracketSize ~/ 2;
    // We have 'byesCount' matches that will be Player vs Bye.
    // The rest (totalRound1Matches - byesCount) will be Player vs Player.
    
    int playerIndex = 0;
    
    for (int i = 0; i < totalRound1Matches; i++) {
      final isByeMatch = i < byesCount;
      
      final player1 = shuffledPlayers[playerIndex++];
      Player? player2;
      
      if (!isByeMatch) {
        player2 = shuffledPlayers[playerIndex++];
      }
      
      // Create the match
      matches.add(TennisMatch(
        id: _uuid.v4(),
        tournamentId: tournament.id,
        tournamentName: tournament.name,
        opponentName: isByeMatch ? 'BYE' : player2!.name,
        time: DateTime.now().add(Duration(days: 1, hours: i)), // Placeholder time
        court: 'Court ${i + 1}',
        round: '1',
        status: isByeMatch ? 'Completed' : 'Scheduled',
        score: isByeMatch ? 'Bye' : null,
        winner: isByeMatch ? player1.name : null,
        // We might need to store player IDs to track progression properly
        // For now, relying on names or we should add playerIds to TennisMatch model
      ));
    }

    return matches;
  }

  int _nextPowerOfTwo(int n) {
    int count = 0;
    if (n > 0 && (n & (n - 1)) == 0) return n;
    while (n != 0) {
      n >>= 1;
      count += 1;
    }
    return 1 << count;
  }
}
