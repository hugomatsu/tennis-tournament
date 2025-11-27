import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tennis_tournament/features/matches/data/match_repository.dart';
import 'package:tennis_tournament/features/matches/domain/match.dart';
import 'package:tennis_tournament/features/tournaments/domain/tournament.dart';
import 'package:tennis_tournament/features/tournaments/presentation/widgets/match_card.dart';

import 'package:tennis_tournament/features/players/presentation/profile_screen.dart';
import 'package:tennis_tournament/features/tournaments/presentation/widgets/painters/bracket_painter.dart';

final bracketMatchesProvider = StreamProvider.family<List<TennisMatch>, String>((ref, tournamentId) {
  return ref.watch(matchRepositoryProvider).watchMatchesForTournament(tournamentId);
});

class BracketView extends ConsumerWidget {
  final Tournament tournament;

  const BracketView({super.key, required this.tournament});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matchesAsync = ref.watch(bracketMatchesProvider(tournament.id));
    final currentUserAsync = ref.watch(currentUserProvider);
    final currentUserId = currentUserAsync.asData?.value?.id;

    return matchesAsync.when(
      data: (matches) {
        if (matches.isEmpty) {
          return const Center(child: Text('No matches generated yet'));
        }

        // Group matches by round
        final rounds = <int, List<TennisMatch>>{};
        for (var match in matches) {
          final r = int.tryParse(match.round) ?? 0;
          if (r > 0) {
            rounds.putIfAbsent(r, () => []).add(match);
          }
        }

        // Sort rounds
        final sortedRounds = rounds.keys.toList()..sort();
        final maxRound = sortedRounds.isNotEmpty ? sortedRounds.last : 0;

        // Sort matches within rounds by index
        for (var r in sortedRounds) {
          rounds[r]!.sort((a, b) => a.matchIndex.compareTo(b.matchIndex));
        }

        const cardHeight = 100.0;
        const cardWidth = 220.0;
        const gap = 50.0; // Horizontal gap
        const margin = 20.0; // Vertical margin between slots in Round 1

        // Calculate total size
        final totalSlots = 1 << (maxRound - 1);
        final totalHeight = totalSlots * (cardHeight + margin) + 100; // Extra padding
        final totalWidth = maxRound * (cardWidth + gap) + 100;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SizedBox(
              width: totalWidth,
              height: totalHeight,
              child: Stack(
                children: [
                  // 1. Painter for lines
                  Positioned.fill(
                    child: CustomPaint(
                      painter: BracketPainter(
                        matches: matches,
                        cardHeight: cardHeight,
                        cardWidth: cardWidth,
                        gap: gap,
                        margin: margin,
                      ),
                    ),
                  ),
                  // 2. Matches
                  ...sortedRounds.map((r) {
                    final roundMatches = rounds[r]!;
                    final xOffset = (r - 1) * (cardWidth + gap);
                    
                    return Positioned(
                      left: xOffset,
                      top: 0,
                      bottom: 0,
                      width: cardWidth,
                      child: Stack(
                        children: roundMatches.map((match) {
                          final yOffset = _calculateY(r, match.matchIndex, cardHeight, margin);
                          final isFinal = r == maxRound && roundMatches.length == 1;

                          return Positioned(
                            top: yOffset,
                            left: 0,
                            child: MatchCard(
                              match: match,
                              width: cardWidth,
                              height: cardHeight,
                              isFinal: isFinal,
                              currentUserId: currentUserId,
                              onTap: () {
                                // Check if admin
                                final user = currentUserAsync.asData?.value;
                                if (user?.userType == 'admin') {
                                  _showScoreDialog(context, ref, match);
                                }
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }

  double _calculateY(int round, int index, double cardHeight, double margin) {
    final slotHeight = cardHeight + margin;
    final slotsPerMatch = 1 << (round - 1); // 2^(r-1)
    
    final blockTop = index * slotsPerMatch * slotHeight;
    final blockHeight = slotsPerMatch * slotHeight;
    final center = blockTop + blockHeight / 2;
    
    return center - cardHeight / 2;
  }

  void _showScoreDialog(BuildContext context, WidgetRef ref, TennisMatch match) {
    final formKey = GlobalKey<FormState>();
    final scoreController = TextEditingController(text: match.score);
    String? selectedWinner = match.winner;

    // Default to player 1 if no winner selected yet
    if (selectedWinner == null && match.player1Name != 'TBD') {
      selectedWinner = match.player1Name;
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Update Score'),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: scoreController,
                    decoration: const InputDecoration(
                      labelText: 'Score (e.g. 6-4, 6-2)',
                      hintText: 'Enter set scores',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a score';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedWinner,
                    decoration: const InputDecoration(labelText: 'Winner'),
                    items: [
                      if (match.player1Name != 'TBD')
                        DropdownMenuItem(
                          value: match.player1Name,
                          child: Text(match.player1Name),
                        ),
                      if (match.player2Name != null && match.player2Name != 'TBD')
                        DropdownMenuItem(
                          value: match.player2Name,
                          child: Text(match.player2Name!),
                        ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedWinner = value;
                      });
                    },
                    validator: (value) => value == null ? 'Select a winner' : null,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () async {
                  if (formKey.currentState!.validate() && selectedWinner != null) {
                    try {
                      await ref.read(matchRepositoryProvider).updateMatchScore(
                            match.id,
                            scoreController.text,
                            selectedWinner!,
                          );
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Score updated!')),
                        );
                        // Refresh matches - Stream will auto-update
                        // ref.invalidate(matchesForTournamentProvider(match.tournamentId));
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e')),
                        );
                      }
                    }
                  }
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }
}
