import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tennis_tournament/features/matches/data/match_repository.dart';
import 'package:tennis_tournament/features/matches/domain/match.dart';
import 'package:tennis_tournament/features/tournaments/domain/tournament.dart';
import 'package:tennis_tournament/features/tournaments/presentation/widgets/match_card.dart';

import 'package:tennis_tournament/features/players/application/player_providers.dart';
import 'package:tennis_tournament/features/tournaments/application/tournament_providers.dart';
import 'package:tennis_tournament/features/tournaments/presentation/widgets/painters/bracket_painter.dart';

final bracketMatchesProvider = StreamProvider.family<List<TennisMatch>, String>((ref, tournamentId) {
  return ref.watch(matchRepositoryProvider).watchMatchesForTournament(tournamentId);
});

class BracketView extends ConsumerWidget {
  final Tournament tournament;

  const BracketView({super.key, required this.tournament});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(tournamentCategoriesProvider(tournament.id));

    return categoriesAsync.when(
      data: (categories) {
        if (categories.isEmpty) {
          return const Center(child: Text('No categories found. Please create a category.'));
        }

        return DefaultTabController(
          length: categories.length,
          child: Column(
            children: [
              Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: TabBar(
                  isScrollable: true,
                  tabs: categories.map((c) => Tab(text: c.name)).toList(),
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: categories.map((c) {
                    return _SingleBracketView(
                      tournamentId: tournament.id,
                      categoryId: c.id,
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error loading categories: $err')),
    );
  }
}

class _SingleBracketView extends ConsumerWidget {
  final String tournamentId;
  final String categoryId;

  const _SingleBracketView({
    required this.tournamentId,
    required this.categoryId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matchesAsync = ref.watch(bracketMatchesProvider(tournamentId));
    final currentUserAsync = ref.watch(currentUserProvider);
    final currentUserId = currentUserAsync.asData?.value?.id;

    return matchesAsync.when(
      data: (allMatches) {
        // Filter matches by category
        final matches = allMatches.where((m) => m.categoryId == categoryId).toList();

        if (matches.isEmpty) {
      final participantsAsync = ref.watch(participantsProvider(tournamentId));
      return participantsAsync.when(
        data: (participants) {
          final categoryParticipants = participants
              .where((p) => p.categoryId == categoryId && p.status == 'approved')
              .toList();
          
          if (categoryParticipants.isEmpty) {
            return const Center(child: Text('No matches generated and no players in this category yet.'));
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('No matches generated yet.'),
                const SizedBox(height: 16),
                Text(
                  'Players in this category (${categoryParticipants.length}):',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: categoryParticipants.map((p) {
                    final url = p.avatarUrls.firstOrNull;
                    return Chip(
                    avatar: CircleAvatar(
                      backgroundImage: url != null ? NetworkImage(url) : null,
                      child: url == null ? Text(p.name.isNotEmpty ? p.name[0] : '?') : null,
                    ),
                    label: Text(p.name),
                  );
                  }).toList(),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error loading players: $e')),
      );
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
                                context.push('/matches/${match.id}');
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

}
