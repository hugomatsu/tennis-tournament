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
    
    // 3. Generate the full bracket tree
    // We need to generate matches for all rounds.
    // Round 1 has bracketSize / 2 matches.
    // Round 2 has bracketSize / 4 matches.
    // ...
    // Final has 1 match.
    
    // We'll store matches in a map by (round, index) to link them easily.
    // Key: "round_index"
    final matchMap = <String, TennisMatch>{};
    
    int totalRounds = 0;
    int temp = bracketSize;
    while (temp > 1) {
      temp >>= 1;
      totalRounds++;
    }

    // Generate matches from Final (Round N) down to Round 1?
    // Or Round 1 up to Final?
    // Let's go Round 1 to Final.
    
    int matchesInRound = bracketSize ~/ 2;
    int playerIndex = 0;

    for (int r = 1; r <= totalRounds; r++) {
      for (int i = 0; i < matchesInRound; i++) {
        final matchId = _uuid.v4();
        
        // Determine players for Round 1
        String player1Id = '';
        String player1Name = 'TBD';
        String? player1Avatar;
        String? player2Id;
        String? player2Name;
        String? player2Avatar;
        String status = 'Pending';
        String? winner;
        String? score;

        if (r == 1) {
          final isByeMatch = i < byesCount;
          
          final p1 = shuffledPlayers[playerIndex++];
          player1Id = p1.id;
          player1Name = p1.name;
          player1Avatar = p1.avatarUrl;

          if (isByeMatch) {
            status = 'Completed';
            winner = p1.name;
            score = 'Bye';
            // Player 2 is null/Bye
          } else {
            final p2 = shuffledPlayers[playerIndex++];
            player2Id = p2.id;
            player2Name = p2.name;
            player2Avatar = p2.avatarUrl;
            status = 'Scheduled';
          }
        } else {
          // For subsequent rounds, players are TBD initially
          // Unless they are advanced from byes in previous round (logic handled by update match, 
          // but for initial generation we can just set TBD or propagate Byes if we want to be fancy.
          // For MVP, let's just create the structure. 
          // Ideally, if R1 has a Bye, the winner should propagate to R2 immediately.
          // But that requires knowing the next match ID.
          // So maybe we should generate matches first, then link?
        }

        final match = TennisMatch(
          id: matchId,
          tournamentId: tournament.id,
          tournamentName: tournament.name,
          player1Id: player1Id,
          player1Name: player1Name,
          player1AvatarUrl: player1Avatar,
          player2Id: player2Id,
          player2Name: player2Name,
          player2AvatarUrl: player2Avatar,
          opponentName: player2Name ?? 'BYE',
          time: DateTime.now().add(Duration(days: r, hours: i)), // Staggered times
          court: 'Court ${i + 1}',
          round: r.toString(),
          status: status,
          score: score,
          winner: winner,
          matchIndex: i,
        );
        
        matchMap['${r}_$i'] = match;
        matches.add(match);
      }
      matchesInRound ~/= 2;
    }

    // Link matches (Next Match ID) and propagate Byes
    // We need to update the matches in the list with nextMatchId
    // And potentially update players for Round 2 if Round 1 was a Bye.
    

    
    // Sort matches by round to process in order
    matches.sort((a, b) {
      final rA = int.parse(a.round);
      final rB = int.parse(b.round);
      return rA.compareTo(rB);
    });

    // We need a mutable map to update matches as we propagate
    final mutableMatchMap = {for (var m in matches) m.id: m};
    // Also map by position for easy lookup
    final positionMap = <String, String>{}; // "round_index" -> matchId
    for (var m in matches) {
      positionMap['${m.round}_${m.matchIndex}'] = m.id;
    }

    for (var match in matches) {
      final r = int.parse(match.round);
      final idx = match.matchIndex;
      
      // Find next match
      if (r < totalRounds) {
        final nextRound = r + 1;
        final nextIndex = idx ~/ 2;
        final nextMatchId = positionMap['${nextRound}_$nextIndex'];
        
        if (nextMatchId != null) {
           // Update current match with nextMatchId
           var updatedMatch = mutableMatchMap[match.id]!.copyWith(nextMatchId: nextMatchId);
           mutableMatchMap[match.id] = updatedMatch;
           
           // Propagate winner if this match is already completed (Bye)
           if (updatedMatch.status == 'Completed' && updatedMatch.winner != null) {
             final nextMatch = mutableMatchMap[nextMatchId]!;
             final isPlayer1Slot = (idx % 2) == 0;
             
             // We need to find the player object to get ID and Avatar. 
             // Since we only stored name in winner, we might need to look up.
             // But wait, if it's a Bye, player1 is the winner.
             
             String? winnerId;
             String? winnerName;
             String? winnerAvatar;
             
             if (updatedMatch.winner == updatedMatch.player1Name) {
               winnerId = updatedMatch.player1Id;
               winnerName = updatedMatch.player1Name;
               winnerAvatar = updatedMatch.player1AvatarUrl;
             } else {
               winnerId = updatedMatch.player2Id;
               winnerName = updatedMatch.player2Name;
               winnerAvatar = updatedMatch.player2AvatarUrl;
             }

             if (winnerId != null) {
                // Update next match
                TennisMatch newNextMatch;
                if (isPlayer1Slot) {
                  newNextMatch = nextMatch.copyWith(
                    player1Id: winnerId,
                    player1Name: winnerName!,
                    player1AvatarUrl: winnerAvatar,
                  );
                } else {
                  newNextMatch = nextMatch.copyWith(
                    player2Id: winnerId,
                    player2Name: winnerName,
                    player2AvatarUrl: winnerAvatar,
                    opponentName: winnerName!, // Legacy
                  );
                }
                
                // If next match now has 2 players, set status to Scheduled? 
                // Only if both slots are filled.
                // For now, just update the player info.
                mutableMatchMap[nextMatchId] = newNextMatch;
             }
           }
        }
      }
    }

    return mutableMatchMap.values.toList();
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
