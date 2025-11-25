import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tennis_tournament/features/matches/data/match_repository.dart';
import 'package:tennis_tournament/features/matches/domain/match.dart';
import 'package:tennis_tournament/features/tournaments/domain/tournament.dart';
import 'package:tennis_tournament/features/tournaments/presentation/widgets/match_card.dart';

class BracketView extends ConsumerWidget {
  final Tournament tournament;

  const BracketView({super.key, required this.tournament});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matchesAsync = ref.watch(matchesForTournamentProvider(tournament.id));

    return matchesAsync.when(
      data: (matches) {
        if (matches.isEmpty) {
          return const Center(child: Text('Bracket not generated yet'));
        }

        // Group matches by round
        final rounds = <int, List<TennisMatch>>{};
        for (var match in matches) {
          final roundInt = int.tryParse(match.round) ?? 0;
          rounds.putIfAbsent(roundInt, () => []).add(match);
        }

        final sortedRounds = rounds.keys.toList()..sort();

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: sortedRounds.map((round) {
              final roundMatches = rounds[round]!;
              // Sort matches by index to keep bracket structure
              roundMatches.sort((a, b) => a.matchIndex.compareTo(b.matchIndex));

              return Container(
                width: 280,
                margin: const EdgeInsets.only(right: 16),
                child: Column(
                  children: [
                    Text(
                      'Round $round',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    // Use a column for matches in the round
                    // In a real bracket, we'd want precise spacing to align connectors
                    // For MVP, a simple list is sufficient
                    ...roundMatches.map((match) => MatchCard(match: match)),
                  ],
                ),
              );
            }).toList(),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }
}
